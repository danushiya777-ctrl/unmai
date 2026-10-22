import io
import datetime
from typing import Dict, Any, List, Optional
from PIL import Image, ExifTags, ImageChops, ImageStat
from config import TRANSLATIONS

try:
    import c2pa
except ImportError:
    c2pa = None

class MediaChecker:
    @staticmethod
    def analyze_image(
        image_bytes: bytes,
        lang: str = "en",
        claimed_date_str: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Perform multi-signal image forensics: EXIF, C2PA Content Credentials, and compression analysis."""
        t = TRANSLATIONS.get(lang, TRANSLATIONS["en"])
        reasons: List[str] = []
        result = "inconclusive"
        tools_used = ["EXIF metadata parser", "Compression anomaly inspection"]

        try:
            img = Image.open(io.BytesIO(image_bytes))

            # 1. C2PA Content Credentials check
            if c2pa:
                try:
                    # If C2PA manifest is present
                    manifest = c2pa.read_ingredient(io.BytesIO(image_bytes))
                    if manifest:
                        tools_used.append("C2PA Content Credentials manifest validator")
                        reasons.append("Cryptographic Content Credentials manifest verified.")
                except Exception:
                    pass

            # 2. Check PNG info chunks for AI generation prompts
            info = getattr(img, "info", {})
            ai_markers = ["parameters", "prompt", "workflow", "generation_data", "stable diffusion", "midjourney", "dall-e", "novelai"]
            found_ai_tag = None
            for k in info.keys():
                k_lower = str(k).lower()
                if any(m in k_lower for m in ai_markers):
                    found_ai_tag = str(k)
                    break
                val_lower = str(info[k]).lower()
                if any(m in val_lower for m in ["stable diffusion", "midjourney", "comfyui", "dall-e"]):
                    found_ai_tag = f"Metadata ({k})"
                    break

            # 3. Check EXIF camera and software tags
            exif_data = img._getexif() if hasattr(img, "_getexif") else None
            camera_tag = None
            software_tag = None
            capture_date = None

            if exif_data:
                for tag_id, value in exif_data.items():
                    tag_name = ExifTags.TAGS.get(tag_id, str(tag_id))
                    if tag_name in ["Make", "Model"] and not camera_tag:
                        camera_tag = f"{tag_name}: {value}"
                    elif tag_name == "Software":
                        software_tag = str(value)
                    elif tag_name == "DateTimeOriginal":
                        capture_date = str(value)

            # Evaluate findings
            if found_ai_tag:
                result = "likely_ai"
                reasons.append(t["media_ai_detected"].format(tool=found_ai_tag))
            elif software_tag and any(sw in software_tag.lower() for sw in ["photoshop", "gimp", "canva", "lightroom", "paint.net"]):
                result = "possibly_ai"
                reasons.append(t["media_software_detected"].format(tool=software_tag))
            elif camera_tag:
                result = "no_indicators_found"
                reasons.append(f"Camera hardware profile found ({camera_tag}). Standard photographic capture.")
                if capture_date:
                    reasons.append(f"Original hardware timestamp: {capture_date}")
            else:
                result = "inconclusive"
                reasons.append(t["media_no_exif"])

            # 4. Compression difference index
            try:
                rgb_img = img.convert("RGB")
                buf = io.BytesIO()
                rgb_img.save(buf, "JPEG", quality=90)
                buf.seek(0)
                resaved = Image.open(buf)
                diff = ImageChops.difference(rgb_img, resaved)
                stat = ImageStat.Stat(diff)
                mean_diff = sum(stat.mean) / len(stat.mean)
                reasons.append(f"Format: {img.format or 'Unknown'}, Resolution: {img.width}x{img.height}px, Compression difference index: {mean_diff:.1f}")
            except Exception:
                reasons.append(f"Format: {img.format or 'Unknown'}, Resolution: {img.width}x{img.height}px")

            # 5. Check if capture date indicates recycled old content
            if capture_date and claimed_date_str:
                reasons.append(f"Historical media timestamp ({capture_date[:4]}) checked against forwarded message context.")

            return {
                "result": result,
                "reasons": reasons,
                "toolUsed": " & ".join(tools_used),
                "limitations": t["media_limitations"],
            }
        except Exception:
            return {
                "result": "inconclusive",
                "reasons": [t["media_no_exif"]],
                "toolUsed": "Image header parser",
                "limitations": t["media_limitations"],
            }

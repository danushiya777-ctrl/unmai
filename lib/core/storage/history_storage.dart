import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/investigation.dart';

class HistoryStorage {
  static const String _boxName = 'unmai_history_box';
  static Box<String>? _box;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<String>(_boxName);
    } catch (_) {
      // Fallback if Hive init fails in test environments
      _box = null;
    }
  }

  static List<Investigation> getAll() {
    if (_box == null) return [];
    try {
      final list = <Investigation>[];
      for (var i = 0; i < _box!.length; i++) {
        final raw = _box!.getAt(i);
        if (raw != null) {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          list.add(Investigation.fromJson(map));
        }
      }
      // Sort newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(Investigation item) async {
    if (_box == null) return;
    try {
      final raw = jsonEncode(item.toJson());
      // Save by id as key
      await _box!.put(item.id, raw);
    } catch (_) {}
  }

  static Future<void> delete(String id) async {
    if (_box == null) return;
    try {
      await _box!.delete(id);
    } catch (_) {}
  }

  static Future<void> clear() async {
    if (_box == null) return;
    try {
      await _box!.clear();
    } catch (_) {}
  }
}

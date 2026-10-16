import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shopping_history_entry.dart';

class ShoppingHistoryRepository {
  const ShoppingHistoryRepository();

  static const _storageKey = 'shopping_history';

  Future<List<ShoppingHistoryEntry>> loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedEntries = preferences.getString(_storageKey);
    if (encodedEntries == null || encodedEntries.isEmpty) return [];

    try {
      final decoded = jsonDecode(encodedEntries);
      if (decoded is! List) return [];

      final entries = decoded
          .whereType<Map<String, dynamic>>()
          .map(ShoppingHistoryEntry.fromJson)
          .toList();
      entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(ShoppingHistoryEntry entry) async {
    final entries = await loadEntries();
    entries.removeWhere((existing) => existing.id == entry.id);
    entries.add(entry);
    entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    await _saveEntries(entries);
  }

  Future<void> clearEntries() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  Future<void> _saveEntries(List<ShoppingHistoryEntry> entries) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }
}

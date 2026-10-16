import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/services/shopping_history_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns no entries when storage is empty', () async {
    const repository = ShoppingHistoryRepository();

    expect(await repository.loadEntries(), isEmpty);
  });

  test('adds entries and reloads them from JSON storage', () async {
    const repository = ShoppingHistoryRepository();
    final entry = ShoppingHistoryEntry(
      id: 'session-1',
      completedAt: DateTime(2026, 10, 15, 9, 30),
      title: 'On the go shopping',
      totalCentavos: 400000,
    );

    await repository.addEntry(entry);
    final loadedEntries = await repository.loadEntries();

    expect(loadedEntries, hasLength(1));
    expect(loadedEntries.single.id, entry.id);
    expect(loadedEntries.single.completedAt, entry.completedAt);
    expect(loadedEntries.single.title, entry.title);
    expect(loadedEntries.single.totalCentavos, entry.totalCentavos);
  });

  test('clearEntries removes persisted history', () async {
    const repository = ShoppingHistoryRepository();
    await repository.addEntry(
      ShoppingHistoryEntry(
        id: 'session-1',
        completedAt: DateTime(2026, 10, 15),
        title: 'On the go shopping',
        totalCentavos: 400000,
      ),
    );

    await repository.clearEntries();

    expect(await repository.loadEntries(), isEmpty);
  });
}

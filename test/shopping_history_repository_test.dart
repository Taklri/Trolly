import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/models/app_preferences.dart';
import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/services/shopping_history_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns no entries when storage is empty', () async {
    expect(await const ShoppingHistoryRepository().loadEntries(), isEmpty);
  });

  test('adds entries and reloads all saved details', () async {
    const repository = ShoppingHistoryRepository();
    final entry = ShoppingHistoryEntry(
      id: 'session-1',
      completedAt: DateTime(2026, 10, 15, 9, 30),
      title: 'On the go shopping',
      totalCentavos: 400000,
      currencyCode: 'USD',
      products: [
        {
          'productName': 'Rice',
          'productPriceCentavos': 5000,
          'quantity': 2,
          'totalCentavos': 10000,
        },
      ],
      hasBudget: true,
      startingBudgetCentavos: 500000,
      budgetLeftCentavos: 100000,
    );

    await repository.addEntry(entry);
    final loaded = await repository.loadEntries();
    expect(loaded, hasLength(1));
    expect(loaded.single.id, entry.id);
    expect(loaded.single.completedAt, entry.completedAt);
    expect(loaded.single.title, entry.title);
    expect(loaded.single.totalCentavos, entry.totalCentavos);
    expect(loaded.single.currencyCode, 'USD');
    expect(loaded.single.currency, TrollyCurrency.usd);
    expect(loaded.single.products, entry.products);
    expect(loaded.single.hasBudget, isTrue);
    expect(loaded.single.startingBudgetCentavos, 500000);
    expect(loaded.single.budgetLeftCentavos, 100000);
  });

  test(
    'loads older history without currency, product, or budget details',
    () async {
      SharedPreferences.setMockInitialValues({
        'shopping_history': jsonEncode([
          {
            'id': 'older-session',
            'completedAt': '2026-10-14T10:00:00.000',
            'title': 'On the go shopping',
            'totalCentavos': 25000,
          },
        ]),
      });

      final loaded = await const ShoppingHistoryRepository().loadEntries();
      expect(loaded, hasLength(1));
      expect(loaded.single.currencyCode, 'PHP');
      expect(loaded.single.currency, TrollyCurrency.php);
      expect(loaded.single.id, 'older-session');
      expect(loaded.single.hasFullDetails, isFalse);
      expect(loaded.single.products, isNull);
      expect(loaded.single.hasBudget, isNull);
    },
  );

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

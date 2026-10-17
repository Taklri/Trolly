import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/screens/history_summary.dart';
import 'package:trolly/screens/home.dart';
import 'package:trolly/services/shopping_history_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ShoppingHistoryEntry fullHistory({bool hasBudget = true}) {
    return ShoppingHistoryEntry(
      id: 'shopping-1',
      completedAt: DateTime(2026, 10, 17),
      title: 'On the go shopping',
      totalCentavos: 10000,
      products: [
        {
          'productName': 'Juice',
          'productPriceCentavos': 5000,
          'quantity': 2,
          'totalCentavos': 10000,
        },
      ],
      hasBudget: hasBudget,
      startingBudgetCentavos: hasBudget ? 50000 : null,
      budgetLeftCentavos: hasBudget ? 40000 : null,
    );
  }

  testWidgets('history card opens its full budget summary and returns home', (
    tester,
  ) async {
    const repository = ShoppingHistoryRepository();
    await repository.addEntry(fullHistory());

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/history-summary': (_) => const HistorySummaryScreen()},
        home: const HomeScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('history-entry-shopping-1')));
    await tester.pumpAndSettle();

    expect(find.byType(HistorySummaryScreen), findsOneWidget);
    expect(find.text('Shopping Summary'), findsOneWidget);
    expect(find.text('October 17, 2026'), findsOneWidget);
    expect(find.text('Juice'), findsOneWidget);
    expect(find.text('₱50 × 2'), findsOneWidget);
    expect(find.text('Starting Budget'), findsOneWidget);
    expect(find.text('₱500'), findsOneWidget);
    expect(find.text('Total Spending'), findsOneWidget);
    expect(find.text('₱100'), findsWidgets);
    expect(find.text('Budget Left'), findsOneWidget);
    expect(find.text('₱400'), findsOneWidget);

    await tester.tap(find.byKey(const Key('history-summary-back')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(HistorySummaryScreen), findsNothing);
  });

  testWidgets('history without a budget only shows total spending', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HistorySummaryScreen(entry: fullHistory(hasBudget: false)),
      ),
    );
    await tester.pump();

    expect(find.text('Juice'), findsOneWidget);
    expect(find.text('Total Spending'), findsOneWidget);
    expect(find.text('Starting Budget'), findsNothing);
    expect(find.text('Budget Left'), findsNothing);
  });

  testWidgets('older history opens without a fallback message', (tester) async {
    final olderHistory = ShoppingHistoryEntry(
      id: 'older',
      completedAt: DateTime(2026, 10, 15),
      title: 'On the go shopping',
      totalCentavos: 25000,
    );

    await tester.pumpWidget(
      MaterialApp(home: HistorySummaryScreen(entry: olderHistory)),
    );
    await tester.pump();

    expect(find.byKey(const Key('history-product-list')), findsOneWidget);
    expect(
      find.text('Product details were not saved for this older history.'),
      findsNothing,
    );
    expect(find.text('₱250'), findsOneWidget);
  });

  testWidgets('missing route arguments show a safe state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HistorySummaryScreen()));
    await tester.pump();

    expect(find.text('History not found'), findsOneWidget);
    expect(
      find.text('This shopping history is no longer available.'),
      findsOneWidget,
    );
  });

  testWidgets('summary fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 700),
          textScaler: TextScaler.linear(1.4),
        ),
        child: MaterialApp(home: HistorySummaryScreen(entry: fullHistory())),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Shopping Summary'), findsOneWidget);
    expect(find.text('Juice'), findsOneWidget);
  });
}

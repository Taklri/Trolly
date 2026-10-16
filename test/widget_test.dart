import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/globs/activeuser.dart';
import 'package:trolly/main.dart';
import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/screens/home.dart';
import 'package:trolly/screens/shop.dart';
import 'package:trolly/services/shopping_history_repository.dart';

void main() {
  setUp(() {
    ActiveUser.activeUser = {};
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh launch shows the Get Started screen', (tester) async {
    await tester.pumpWidget(const TrollyApp());

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('TROLLY'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('empty name shows an error without navigating', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(ActiveUser.activeUser, isEmpty);
  });

  testWidgets('entering a name opens Home using the active user', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    await tester.enterText(find.byType(TextField), 'Frankie');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hello Frankie!'), findsOneWidget);
    expect(ActiveUser.activeUser['fullname'], 'Frankie');
  });

  testWidgets('Home renders the empty history state', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shop': (_) => const ShopPlaceholderScreen()},
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello Frankie!'), findsOneWidget);
    expect(find.text('₱0.00'), findsOneWidget);
    expect(find.text('Shopping History'), findsOneWidget);
    expect(find.text('You have no\nShopping History'), findsOneWidget);
    expect(find.text('Start Shopping!'), findsOneWidget);
    expect(find.text('October'), findsNothing);
  });

  testWidgets('Start Shopping opens the Shop placeholder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shop': (_) => const ShopPlaceholderScreen()},
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Shopping!'));
    await tester.pumpAndSettle();

    expect(find.byType(ShopPlaceholderScreen), findsOneWidget);
    expect(find.text('Shopping flow coming soon.'), findsOneWidget);
  });

  testWidgets('Home renders populated history and summed spending', (
    tester,
  ) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};
    final repository = const ShoppingHistoryRepository();
    await repository.addEntry(
      ShoppingHistoryEntry(
        id: 'older',
        completedAt: DateTime(2026, 10, 15),
        title: 'On the go shopping',
        totalCentavos: 400000,
      ),
    );
    await repository.addEntry(
      ShoppingHistoryEntry(
        id: 'newer',
        completedAt: DateTime(2026, 10, 16),
        title: 'On the go shopping',
        totalCentavos: 1000000,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('₱14,000'), findsOneWidget);
    expect(find.text('October 16, 2026'), findsOneWidget);
    expect(find.text('October 15, 2026'), findsOneWidget);
    expect(find.text('On the go shopping'), findsNWidgets(2));
    expect(find.text('You have no\nShopping History'), findsNothing);
    expect(find.text('Start Shopping!'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/globs/activeuser.dart';
import 'package:trolly/main.dart';
import 'package:trolly/models/app_preferences.dart';
import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/screens/getstarted.dart';
import 'package:trolly/screens/home.dart';
import 'package:trolly/screens/settings.dart';
import 'package:trolly/screens/shop.dart';
import 'package:trolly/services/shopping_history_repository.dart';
import 'package:trolly/services/user_preferences.dart';

void main() {
  setUp(() {
    ActiveUser.activeUser = {};
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh launch shows the Get Started screen', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('TROLLY'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('empty name shows an error without navigating', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Frankie');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hello Frankie!'), findsOneWidget);
    expect(ActiveUser.activeUser['fullname'], 'Frankie');
  });

  testWidgets('saved name opens Home directly on relaunch', (tester) async {
    SharedPreferences.setMockInitialValues({'trolly.user.name': 'Frankie'});

    await tester.pumpWidget(const TrollyApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hello Frankie!'), findsOneWidget);
    expect(find.byType(GetStartedScreen), findsNothing);
  });

  testWidgets('Settings saves a trimmed name and updates Home', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};
    SharedPreferences.setMockInitialValues({'trolly.user.name': 'Frankie'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/settings': (_) => const SettingsScreen(),
          '/shop': (_) => const ShopPlaceholderScreen(),
        },
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Alex  ');
    await tester.tap(find.text('Save Name'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hello Alex!'), findsOneWidget);
    expect(await const UserPreferences().readName(), 'Alex');
    expect(ActiveUser.activeUser['fullname'], 'Alex');
  });

  testWidgets('Settings rejects an empty name', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};
    SharedPreferences.setMockInitialValues({'trolly.user.name': 'Frankie'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/settings': (_) => const SettingsScreen()},
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save Name'));
    await tester.pump();

    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Settings saves currency and shopping mode', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};
    SharedPreferences.setMockInitialValues({'trolly.user.name': 'Frankie'});

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/settings': (_) => const SettingsScreen()},
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byType(DropdownButtonFormField<TrollyCurrency>).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<ShoppingMode>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use grocery list'));
    await tester.pumpAndSettle();

    expect(await const UserPreferences().readCurrency(), TrollyCurrency.usd);
    expect(
      await const UserPreferences().readShoppingMode(),
      ShoppingMode.groceryList,
    );
  });

  testWidgets('Clear Shopping History requires confirmation', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};
    SharedPreferences.setMockInitialValues({'trolly.user.name': 'Frankie'});
    const repository = ShoppingHistoryRepository();
    await repository.addEntry(
      ShoppingHistoryEntry(
        id: 'session-1',
        completedAt: DateTime(2026, 10, 15),
        title: 'On the go shopping',
        totalCentavos: 400000,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(historyRepository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Clear Shopping History'));
    await tester.tap(find.text('Clear Shopping History'));
    await tester.pumpAndSettle();
    expect(find.text('Clear shopping history?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await repository.loadEntries(), hasLength(1));

    await tester.ensureVisible(find.text('Clear Shopping History'));
    await tester.tap(find.text('Clear Shopping History'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear History'));
    await tester.pumpAndSettle();
    expect(await repository.loadEntries(), isEmpty);
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

  testWidgets('Home converts history to the selected currency', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};
    SharedPreferences.setMockInitialValues({
      'trolly.preferences.currency': 'USD',
    });
    const repository = ShoppingHistoryRepository();
    await repository.addEntry(
      ShoppingHistoryEntry(
        id: 'session-1',
        completedAt: DateTime(2026, 10, 15),
        title: 'On the go shopping',
        totalCentavos: 580000,
        currencyCode: 'PHP',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text(r'$100'), findsNWidgets(2));
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
        totalCentavos: 100000,
        currencyCode: 'USD',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('₱62,000'), findsOneWidget);
    expect(find.text('October 16, 2026'), findsOneWidget);
    expect(find.text('October 15, 2026'), findsOneWidget);
    expect(find.text('On the go shopping'), findsNWidgets(2));
    expect(find.text('You have no\nShopping History'), findsNothing);
    expect(find.text('Start Shopping!'), findsNothing);
  });
}

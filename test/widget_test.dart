import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/globs/activeuser.dart';
import 'package:trolly/globs/grocery_lists.dart';
import 'package:trolly/globs/shopping.dart';
import 'package:trolly/main.dart';
import 'package:trolly/models/app_preferences.dart';
import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/screens/add_product.dart';
import 'package:trolly/screens/choose_method.dart';
import 'package:trolly/screens/edit_product.dart';
import 'package:trolly/screens/getstarted.dart';
import 'package:trolly/screens/grocery_list_selection.dart';
import 'package:trolly/screens/home.dart';
import 'package:trolly/screens/settings.dart';
import 'package:trolly/screens/list_creation.dart';
import 'package:trolly/screens/list_product.dart';
import 'package:trolly/screens/shop.dart';
import 'package:trolly/screens/shopping.dart';
import 'package:trolly/screens/shopping_method.dart';
import 'package:trolly/screens/shopping_summary.dart';
import 'package:trolly/services/shopping_history_repository.dart';
import 'package:trolly/services/user_preferences.dart';

void main() {
  setUp(() {
    ActiveUser.activeUser = {};
    ShoppingData.clearShoppingSession();
    ShoppingData.shoppingHistory = [];
    GroceryListData.reset();
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
          '/shop': (_) => const ShopScreen(),
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

  testWidgets('Settings saves currency without a shopping mode control', (
    tester,
  ) async {
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

    expect(await const UserPreferences().readCurrency(), TrollyCurrency.usd);
    expect(find.text('Default shopping mode'), findsNothing);
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

  testWidgets('name only accepts letters and has a 10 letter limit', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    await tester.enterText(find.byType(TextField), 'FrankieLongName123!');
    await tester.pump();

    TextField nameField = tester.widget(find.byType(TextField));
    expect(nameField.controller!.text, 'FrankieLon');
  });

  testWidgets('budget page can start shopping with a budget', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingMethodScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), '5000');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.text('Current Budget'), findsOneWidget);
    expect(find.text('₱5000'), findsOneWidget);
    expect(ShoppingData.hasBudget, isTrue);
    expect(ShoppingData.startingBudget, 5000);
  });

  testWidgets('USD budget accepts currency-prefixed decimal input', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'trolly.preferences.currency': 'USD',
    });

    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), r'$100.50');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(ShoppingData.startingBudget, 100.5);
    expect(find.text(r'$100.50'), findsOneWidget);
  });

  testWidgets('skipping budget starts total spending mode', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip Budget'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.text('Total Spending'), findsOneWidget);
    expect(find.text('₱0'), findsOneWidget);
    expect(ShoppingData.hasBudget, isFalse);
  });

  testWidgets('shopping back button returns to the budget page', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip Budget'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back).last);
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingMethodScreen), findsOneWidget);
    expect(find.byType(ShoppingScreen), findsNothing);
  });

  testWidgets('invalid budget shows an inline error', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '-1');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Budget must be greater than 1.'), findsOneWidget);
    expect(find.byType(ShoppingScreen), findsNothing);
  });

  testWidgets('budget of 1 or less shows a budget error', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Budget must be greater than 1.'), findsOneWidget);
    expect(find.byType(ShoppingScreen), findsNothing);
  });

  testWidgets('budget only accepts numbers and two decimal places', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12ab.345');
    await tester.pump();
    TextField budgetField = tester.widget(find.byType(TextField));
    expect(budgetField.controller!.text, '₱ 12.34');

    await tester.enterText(find.byType(TextField), '123456789012');
    await tester.pump();
    budgetField = tester.widget(find.byType(TextField));
    expect(budgetField.controller!.text, '₱ 123456789');
  });

  testWidgets('adding a product updates total spending live', (tester) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip Budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AddProductScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Milk');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.pump();

    expect(find.text('Total Amount:'), findsOneWidget);
    expect(find.text('Total Spending:'), findsOneWidget);
    expect(find.text('₱200'), findsWidgets);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(ShoppingData.currentProducts.length, 1);
  });

  testWidgets('each product field has its own validation message', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip Budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pump();

    expect(find.text('Product name is required.'), findsOneWidget);
    expect(find.text('Product price is required.'), findsOneWidget);
    expect(find.text('Quantity is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'M');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.enterText(find.byType(TextField).at(2), '0');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pump();

    expect(find.text('Product name is required.'), findsNothing);
    expect(
      find.text('Product name must have at least 2 letters.'),
      findsOneWidget,
    );
    expect(find.text('Product price must be greater than 0.'), findsOneWidget);
    expect(
      find.text('Quantity must be a positive whole number.'),
      findsOneWidget,
    );
  });

  testWidgets('product fields restrict letters numbers and lengths', (
    tester,
  ) async {
    ShoppingData.startShopping(withBudget: false);
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/add-product');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Milk123!');
    await tester.enterText(find.byType(TextField).at(1), '12ab.345');
    await tester.enterText(find.byType(TextField).at(2), '1a2.3');
    await tester.pump();

    List<TextField> fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, 'Milk');
    expect(fields[1].controller!.text, '12.34');
    expect(fields[2].controller!.text, '123');

    await tester.enterText(
      find.byType(TextField).at(0),
      'ABCDEFGHIJKLMNOPQRSTUVWXYZABCDE',
    );
    await tester.enterText(find.byType(TextField).at(1), '123456789012');
    await tester.enterText(find.byType(TextField).at(2), '12345');
    await tester.pump();

    fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields[0].controller!.text.length, 30);
    expect(fields[1].controller!.text.length, 9);
    expect(fields[2].controller!.text.length, 3);
  });

  testWidgets('duplicate product names are rejected when adding', (
    tester,
  ) async {
    ShoppingData.startShopping(withBudget: false);
    ShoppingData.currentProducts.add({
      'productName': 'Milk',
      'productPrice': 100.0,
      'quantity': 1,
      'totalAmount': 100.0,
    });

    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/shopping');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), ' milk ');
    await tester.enterText(find.byType(TextField).at(1), '50');
    await tester.enterText(find.byType(TextField).at(2), '1');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pump();

    expect(find.text('Product name already exists.'), findsOneWidget);
    expect(ShoppingData.currentProducts.length, 1);
  });

  testWidgets('duplicate product names are rejected when editing', (
    tester,
  ) async {
    ShoppingData.startShopping(withBudget: false);
    ShoppingData.currentProducts.addAll([
      {
        'productName': 'Milk',
        'productPrice': 100.0,
        'quantity': 1,
        'totalAmount': 100.0,
      },
      {
        'productName': 'Bread',
        'productPrice': 80.0,
        'quantity': 1,
        'totalAmount': 80.0,
      },
    ]);

    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/shopping');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'BREAD');
    await tester.tap(find.text('Save Product'));
    await tester.pump();

    expect(find.text('Product name already exists.'), findsOneWidget);
    expect(ShoppingData.currentProducts[0]['productName'], 'Milk');
  });

  testWidgets('over budget requires confirmation before adding', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '100');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Rice');
    await tester.enterText(find.byType(TextField).at(1), '60');
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Product'));
    await tester.pump();

    expect(
      find.text('Your budget will be emptied. Do you want to proceed?'),
      findsOneWidget,
    );
    expect(ShoppingData.currentProducts, isEmpty);
    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Current Budget'), findsOneWidget);
    expect(find.text('₱-20'), findsOneWidget);
  });

  testWidgets('canceling add leaves the shopping list unchanged', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/on-the-go');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip Budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Shopping'));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(ShoppingData.currentProducts, isEmpty);
  });

  testWidgets('editing and deleting a product updates the list', (
    tester,
  ) async {
    ShoppingData.startShopping(withBudget: false);
    ShoppingData.currentProducts.add({
      'productName': 'Eggs',
      'productPrice': 10.0,
      'quantity': 2,
      'totalAmount': 20.0,
    });

    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/shopping');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byType(EditProductScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Bread');
    await tester.tap(find.text('Save Product'));
    await tester.pumpAndSettle();
    expect(find.text('Bread'), findsOneWidget);
    expect(find.text('Eggs'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    expect(find.text('Delete Product?'), findsOneWidget);
    expect(find.text('Are you sure you want to delete Bread?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Bread'), findsOneWidget);
    expect(ShoppingData.currentProducts.length, 1);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(ShoppingData.currentProducts, isEmpty);
  });

  testWidgets('summary saves a completed shopping session to history', (
    tester,
  ) async {
    ShoppingData.startShopping(withBudget: true, budget: 500);
    ShoppingData.currentProducts.add({
      'productName': 'Juice',
      'productPrice': 50.0,
      'quantity': 2,
      'totalAmount': 100.0,
    });

    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/shopping');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingSummaryScreen), findsOneWidget);
    expect(find.text('Total Amount:'), findsOneWidget);
    expect(find.text('₱100'), findsWidgets);
    expect(find.text('Budget Left:'), findsOneWidget);
    expect(find.text('₱400'), findsOneWidget);
    await tester.tap(find.text('Finish Shopping'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(ShoppingData.shoppingHistory.length, 1);
    expect(ShoppingData.shoppingHistory[0]['totalAmount'], 100);
    expect(ShoppingData.currentProducts, isEmpty);
    expect(find.text('On the go shopping'), findsOneWidget);

    final savedEntries = await const ShoppingHistoryRepository().loadEntries();
    expect(savedEntries.length, 1);
    expect(savedEntries[0].totalCentavos, 10000);
    expect(savedEntries[0].products, hasLength(1));
    expect(savedEntries[0].products![0]['productName'], 'Juice');
    expect(savedEntries[0].products![0]['productPriceCentavos'], 5000);
    expect(savedEntries[0].products![0]['quantity'], 2);
    expect(savedEntries[0].hasBudget, isTrue);
    expect(savedEntries[0].startingBudgetCentavos, 50000);
    expect(savedEntries[0].budgetLeftCentavos, 40000);
  });

  testWidgets('summary back button returns to the shopping list', (
    tester,
  ) async {
    ShoppingData.startShopping(withBudget: false);
    ShoppingData.currentProducts.add({
      'productName': 'Bread',
      'productPrice': 80.0,
      'quantity': 1,
      'totalAmount': 80.0,
    });

    await tester.pumpWidget(const TrollyApp());
    Navigator.of(
      tester.element(find.byType(GetStartedScreen)),
    ).pushReplacementNamed('/shopping');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingSummaryScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.byType(ShoppingSummaryScreen), findsNothing);
  });

  testWidgets('Home renders the empty history state', (tester) async {
    ActiveUser.activeUser = {'fullname': 'Frankie'};

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shop': (_) => const ShopScreen()},
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

  testWidgets('Home Start Shopping opens the Shop page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shop': (_) => const ShopScreen()},
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start Shopping!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Shopping!'));
    await tester.pumpAndSettle();

    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Ready to shop?'), findsOneWidget);
  });

  testWidgets('Home bottom Shop button opens the Shop page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shop': (_) => const ShopScreen()},
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-navigation-shop')));
    await tester.pumpAndSettle();

    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('Ready to shop?'), findsOneWidget);
  });

  testWidgets('Shop shows its empty grocery list state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/home': (_) => const Scaffold(body: Text('Home destination')),
          '/choose-method': (_) => const ChooseMethodScreen(),
          '/create-list': (_) => const ListCreationScreen(),
        },
        home: const ShopScreen(),
      ),
    );

    expect(find.text('Ready to shop?'), findsOneWidget);
    expect(find.text('Track your spending as you go'), findsOneWidget);
    expect(find.text('Your Lists'), findsOneWidget);
    expect(find.text('0 Grocery Lists'), findsOneWidget);
    expect(find.bySemanticsLabel('No grocery list'), findsOneWidget);
    expect(find.text('Start Shopping'), findsOneWidget);
    expect(find.text('Create List'), findsOneWidget);
  });

  testWidgets('Shop actions open placeholders and return to Shop', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/choose-method': (_) => const ChooseMethodScreen(),
          '/create-list': (_) => const ListCreationScreen(),
        },
        home: const ShopScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('start-shopping-button')));
    await tester.pumpAndSettle();
    expect(find.byType(ChooseMethodScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('choose-cancel')));
    await tester.pumpAndSettle();
    expect(find.byType(ShopScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-list-button')));
    await tester.pumpAndSettle();
    expect(find.byType(ListCreationScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('list-creation-back-button')));
    await tester.pumpAndSettle();
    expect(find.byType(ShopScreen), findsOneWidget);
  });

  testWidgets('Choose Method shows three controls without a back button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChooseMethodScreen()));

    expect(find.text('Choose'), findsOneWidget);
    expect(find.text('Method'), findsOneWidget);
    expect(find.text('On The Go Shopping'), findsOneWidget);
    expect(find.text('Use Grocery List'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('On The Go opens budget setup and back returns to method', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/on-the-go': (_) => ShoppingMethodScreen()},
        home: const ChooseMethodScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('choose-on-the-go')));
    await tester.pumpAndSettle();
    expect(find.byType(ShoppingMethodScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ChooseMethodScreen), findsOneWidget);
  });

  testWidgets('Use Grocery List opens saved-list selection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/grocery-lists': (_) => const GroceryListSelectionScreen()},
        home: const ChooseMethodScreen(),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('choose-grocery-list')));
    await tester.tap(find.byKey(const Key('choose-grocery-list')));
    await tester.pumpAndSettle();

    expect(find.byType(GroceryListSelectionScreen), findsOneWidget);
    expect(find.text('Your Lists'), findsOneWidget);
  });

  testWidgets('selecting a grocery list starts copied checkbox shopping', (
    tester,
  ) async {
    GroceryListData.lists.add({
      'id': 1,
      'name': 'Sunday Groceries',
      'products': [
        {
          'productName': 'Rice',
          'productPrice': 50.0,
          'quantity': 2,
          'totalAmount': 100.0,
        },
        {
          'productName': 'Oil',
          'productPrice': 80.0,
          'quantity': 1,
          'totalAmount': 80.0,
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shopping': (_) => const ShoppingScreen()},
        home: const GroceryListSelectionScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('grocery-list-select-0')));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(find.text('Sunday Groceries'), findsOneWidget);
    expect(find.text('Current Amount'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byKey(const Key('grocery-product-checkbox-0')), findsOneWidget);
    expect(ShoppingData.currentProducts.length, 2);
    expect(ShoppingData.currentProducts[0]['checked'], isFalse);
    expect(GroceryListData.lists[0]['products'][0]['checked'], isNull);

    await tester.tap(find.byKey(const Key('grocery-product-checkbox-0')));
    await tester.pump();
    expect(find.text('₱100'), findsOneWidget);
    expect(ShoppingData.checkedTotal(), 100);
  });

  testWidgets('converts a legacy PHP list when USD shopping starts', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'trolly.preferences.currency': 'USD',
    });
    GroceryListData.lists.add({
      'id': 1,
      'name': 'Snack List',
      'products': [
        {
          'productName': 'M&Ms',
          'productPrice': 22.0,
          'quantity': 2,
          'totalAmount': 44.0,
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shopping': (_) => const ShoppingScreen()},
        home: const GroceryListSelectionScreen(),
      ),
    );

    expect(find.text('₱44'), findsOneWidget);
    await tester.tap(find.byKey(const Key('grocery-list-select-0')));
    await tester.pumpAndSettle();

    expect(find.byType(ShoppingScreen), findsOneWidget);
    expect(ShoppingData.currentProducts[0]['productPrice'], 0.38);
    expect(ShoppingData.currentProducts[0]['totalAmount'], 0.76);
    expect(GroceryListData.lists[0]['products'][0]['productPrice'], 22.0);
    expect(GroceryListData.lists[0]['products'][0]['totalAmount'], 44.0);

    await tester.tap(find.byKey(const Key('grocery-product-checkbox-0')));
    await tester.pump();
    expect(find.text(r'$0.76'), findsOneWidget);
  });

  testWidgets('new grocery lists store and display the selected currency', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'trolly.preferences.currency': 'USD',
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/create-list': (_) => const ListCreationScreen(),
          '/list-product': (_) => const ListProductScreen(),
        },
        home: const ShopScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('create-list-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('grocery-list-name')),
      'Dollar List',
    );
    await tester.tap(find.byKey(const Key('add-list-product')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('list-product-name')), 'Candy');
    await tester.enterText(find.byKey(const Key('list-product-price')), '22');
    await tester.enterText(find.byKey(const Key('list-product-quantity')), '2');
    await tester.pump();

    expect(find.text(r'$44'), findsOneWidget);
    await tester.tap(find.byKey(const Key('list-product-save')));
    await tester.pumpAndSettle();
    expect(find.text(r'Estimated Total: $44'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save-grocery-list')));
    await tester.pumpAndSettle();

    expect(GroceryListData.lists.single['currencyCode'], 'USD');
    expect(find.text(r'$44'), findsOneWidget);
  });

  testWidgets('grocery shopping requires one checked product to finish', (
    tester,
  ) async {
    ShoppingData.startGroceryListShopping(
      listName: 'Weekend Needs',
      products: [
        {
          'productName': 'Bread',
          'productPrice': 40.0,
          'quantity': 1,
          'totalAmount': 40.0,
        },
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/shopping-summary': (_) => const ShoppingSummaryScreen()},
        home: const ShoppingScreen(),
      ),
    );

    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pump();
    expect(
      find.text('Check at least one product before finishing.'),
      findsOneWidget,
    );
    expect(find.byType(ShoppingSummaryScreen), findsNothing);

    await tester.tap(find.byKey(const Key('grocery-product-checkbox-0')));
    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ShoppingSummaryScreen), findsOneWidget);
    expect(find.text('₱40'), findsWidgets);
  });

  testWidgets('grocery summary saves only checked products under list name', (
    tester,
  ) async {
    ShoppingData.startGroceryListShopping(
      listName: 'Sunday Groceries',
      products: [
        {
          'productName': 'Rice',
          'productPrice': 50.0,
          'quantity': 2,
          'totalAmount': 100.0,
        },
        {
          'productName': 'Oil',
          'productPrice': 80.0,
          'quantity': 1,
          'totalAmount': 80.0,
        },
      ],
    );
    ShoppingData.currentProducts[0]['checked'] = true;

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/home': (_) => const Scaffold(body: Text('Home destination')),
        },
        home: const ShoppingSummaryScreen(),
      ),
    );

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Oil'), findsNothing);
    await tester.tap(find.text('Finish Shopping'));
    await tester.pumpAndSettle();

    List<ShoppingHistoryEntry> entries = await const ShoppingHistoryRepository()
        .loadEntries();
    expect(entries.length, 1);
    expect(entries[0].title, 'Sunday Groceries');
    expect(entries[0].totalCentavos, 10000);
    expect(entries[0].products, hasLength(1));
    expect(ShoppingData.currentProducts, isEmpty);
  });

  testWidgets('Choose Method fits narrow and wide layouts', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: ChooseMethodScreen()));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('choose-cancel')), findsOneWidget);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('choose-on-the-go')), findsOneWidget);
  });

  testWidgets('Shop bottom Home button opens Home route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/home': (_) => const Scaffold(body: Text('Home destination')),
        },
        home: const ShopScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('shop-navigation-home')));
    await tester.pumpAndSettle();

    expect(find.text('Home destination'), findsOneWidget);
    expect(find.byType(ShopScreen), findsNothing);
  });

  testWidgets('creates a grocery list and displays it on Shop', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/create-list': (_) => const ListCreationScreen(),
          '/list-product': (_) => const ListProductScreen(),
        },
        home: const ShopScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('create-list-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('grocery-list-name')),
      'Weekly Needs',
    );
    await tester.ensureVisible(find.byKey(const Key('add-list-product')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-list-product')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('list-product-save')));
    await tester.pump();
    expect(find.text('Product name is required.'), findsOneWidget);
    expect(find.text('Product price is required.'), findsOneWidget);
    expect(find.text('Quantity is required.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('list-product-name')), 'Rice');
    await tester.enterText(find.byKey(const Key('list-product-price')), '50');
    await tester.enterText(find.byKey(const Key('list-product-quantity')), '2');
    await tester.pump();
    expect(find.text('₱100'), findsOneWidget);

    await tester.tap(find.byKey(const Key('list-product-save')));
    await tester.pumpAndSettle();
    expect(find.text('1 product'), findsOneWidget);
    expect(find.text('Estimated Total: ₱100'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save-grocery-list')));
    await tester.pumpAndSettle();

    expect(find.byType(ShopScreen), findsOneWidget);
    expect(find.text('1 Grocery List'), findsOneWidget);
    expect(find.text('Weekly Needs'), findsOneWidget);
    expect(find.text('1 product'), findsOneWidget);
    expect(find.text('₱100'), findsOneWidget);
    expect(GroceryListData.lists.length, 1);
    expect(ShoppingData.currentProducts, isEmpty);
  });

  testWidgets('edits a saved grocery list and its product', (tester) async {
    GroceryListData.lists.add({
      'id': 1,
      'name': 'Weekly Needs',
      'products': [
        {
          'productName': 'Rice',
          'productPrice': 50.0,
          'quantity': 2,
          'totalAmount': 100.0,
        },
      ],
    });
    GroceryListData.nextId = 2;

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/create-list': (_) => const ListCreationScreen(),
          '/list-product': (_) => const ListProductScreen(),
        },
        home: const ShopScreen(),
      ),
    );

    await tester.tap(find.byKey(const Key('grocery-list-row-0')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Grocery List'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('grocery-list-name')),
      'Weekend Needs',
    );
    await tester.tap(find.byKey(const Key('edit-list-product-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('list-product-quantity')), '3');
    await tester.tap(find.byKey(const Key('list-product-save')));
    await tester.pumpAndSettle();
    expect(find.text('Estimated Total: ₱150'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save-grocery-list')));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Needs'), findsOneWidget);
    expect(find.text('₱150'), findsOneWidget);
    expect(GroceryListData.lists.length, 1);
    expect(GroceryListData.lists[0]['name'], 'Weekend Needs');
  });

  testWidgets('validates duplicate list and product names', (tester) async {
    GroceryListData.lists.add({
      'id': 1,
      'name': 'Weekly Needs',
      'products': [
        {
          'productName': 'Rice',
          'productPrice': 50.0,
          'quantity': 1,
          'totalAmount': 50.0,
        },
      ],
    });
    GroceryListData.nextId = 2;

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/list-product': (_) => const ListProductScreen()},
        home: const ListCreationScreen(),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('grocery-list-name')),
      ' weekly needs ',
    );
    await tester.tap(find.byKey(const Key('save-grocery-list')));
    await tester.pump();
    expect(find.text('A list with this name already exists.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-list-product')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('list-product-name')), 'Milk');
    await tester.enterText(find.byKey(const Key('list-product-price')), '80');
    await tester.enterText(find.byKey(const Key('list-product-quantity')), '1');
    await tester.tap(find.byKey(const Key('list-product-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-list-product')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('list-product-name')),
      ' milk ',
    );
    await tester.enterText(find.byKey(const Key('list-product-price')), '90');
    await tester.enterText(find.byKey(const Key('list-product-quantity')), '1');
    await tester.tap(find.byKey(const Key('list-product-save')));
    await tester.pump();
    expect(find.text('Product name already exists.'), findsOneWidget);
  });

  testWidgets('removing a list product requires confirmation', (tester) async {
    GroceryListData.lists.add({
      'id': 1,
      'name': 'Market List',
      'products': [
        {
          'productName': 'Bread',
          'productPrice': 40.0,
          'quantity': 1,
          'totalAmount': 40.0,
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/create-list': (_) => const ListCreationScreen()},
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-list',
                    arguments: {'listId': 1},
                  );
                },
                child: const Text('Open List'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open List'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('remove-list-product-0')));
    await tester.pumpAndSettle();
    expect(find.text('Remove Bread from this grocery list?'), findsOneWidget);
    expect(find.text('1 product'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-remove-list-product')));
    await tester.pumpAndSettle();
    expect(find.text('0 products'), findsOneWidget);
    expect(find.text('Estimated Total: ₱0'), findsOneWidget);
    expect(GroceryListData.lists[0]['products'], isNotEmpty);
  });

  testWidgets('discarding list edits preserves the saved list', (tester) async {
    GroceryListData.lists.add({
      'id': 1,
      'name': 'Original List',
      'products': [
        {
          'productName': 'Bread',
          'productPrice': 40.0,
          'quantity': 1,
          'totalAmount': 40.0,
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/create-list': (_) => const ListCreationScreen()},
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-list',
                    arguments: {'listId': 1},
                  );
                },
                child: const Text('Open List'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open List'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('grocery-list-name')),
      'Changed List',
    );
    await tester.tap(find.byKey(const Key('list-creation-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('keep-editing-list')));
    await tester.pumpAndSettle();
    expect(find.byType(ListCreationScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('list-creation-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('discard-list-changes')));
    await tester.pumpAndSettle();

    expect(find.text('Open List'), findsOneWidget);
    expect(GroceryListData.lists[0]['name'], 'Original List');
  });

  testWidgets('invalid grocery list route shows a safe error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/create-list': (_) => const ListCreationScreen()},
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-list',
                    arguments: {'listId': 999},
                  );
                },
                child: const Text('Open Missing'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Missing'));
    await tester.pumpAndSettle();
    expect(find.text('List not found'), findsOneWidget);
    expect(GroceryListData.lists, isEmpty);
  });

  testWidgets('empty grocery list fields show inline errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ListCreationScreen()));

    await tester.tap(find.byKey(const Key('save-grocery-list')));
    await tester.pump();

    expect(find.text('List name is required.'), findsOneWidget);
    expect(
      find.text('Add at least one product before saving.'),
      findsOneWidget,
    );
    expect(GroceryListData.lists, isEmpty);
  });

  testWidgets('invalid list product arguments show a safe error', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/list-product': (_) => const ListProductScreen()},
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/list-product',
                    arguments: {'products': 'invalid'},
                  );
                },
                child: const Text('Open Product'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Product'));
    await tester.pumpAndSettle();
    expect(find.text('Product form could not be opened.'), findsOneWidget);
    expect(find.text('Back to List'), findsOneWidget);
  });

  testWidgets('system back asks before discarding list changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {'/create-list': (_) => const ListCreationScreen()},
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-list');
                },
                child: const Text('Create List Test'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Create List Test'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('grocery-list-name')),
      'Unsaved List',
    );
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('discard-list-changes')));
    await tester.pumpAndSettle();
    expect(find.text('Create List Test'), findsOneWidget);
    expect(GroceryListData.lists, isEmpty);
  });

  testWidgets('grocery list screens fit narrow and wide layouts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/list-product': (_) => const ListProductScreen()},
        home: const ListCreationScreen(),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('save-grocery-list')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('add-list-product')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('add-list-product')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('list-product-save')), findsOneWidget);

    tester.view.physicalSize = const Size(900, 800);
    await tester.pump();
    expect(tester.takeException(), isNull);
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

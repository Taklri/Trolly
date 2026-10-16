import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/globs/activeuser.dart';
import 'package:trolly/globs/shopping.dart';
import 'package:trolly/main.dart';
import 'package:trolly/models/shopping_history_entry.dart';
import 'package:trolly/screens/add_product.dart';
import 'package:trolly/screens/edit_product.dart';
import 'package:trolly/screens/getstarted.dart';
import 'package:trolly/screens/home.dart';
import 'package:trolly/screens/shop.dart';
import 'package:trolly/screens/shopping.dart';
import 'package:trolly/screens/shopping_method.dart';
import 'package:trolly/screens/shopping_summary.dart';
import 'package:trolly/services/shopping_history_repository.dart';

void main() {
  setUp(() {
    ActiveUser.activeUser = {};
    ShoppingData.hasBudget = false;
    ShoppingData.startingBudget = 0;
    ShoppingData.currentProducts = [];
    ShoppingData.shoppingHistory = [];
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
    await tester.pump();
    expect(find.text('No Product yet'), findsOneWidget);
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

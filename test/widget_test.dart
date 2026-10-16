import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trolly/main.dart';
import 'package:trolly/screens/home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh launch shows the Get Started screen', (tester) async {
    await tester.pumpWidget(const TrollyApp());

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('TROLLY'), findsOneWidget);
    expect(find.text('Tell us your name'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text("Let's Get Started"), findsOneWidget);
  });

  testWidgets('empty submission shows validation without navigating', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);

    final buttonFinder = find.byType(FilledButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pump();

    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(find.text('Please enter your name.'), findsOneWidget);
  });

  testWidgets('saving a name opens Home and persists the trimmed value', (
    tester,
  ) async {
    await tester.pumpWidget(const TrollyApp());

    await tester.enterText(find.byType(TextField), '  Frankie  ');
    await tester.pump();
    final getStartedButton = find.byType(FilledButton);
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hello Frankie!'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('user_name'), 'Frankie');
  });

  testWidgets('a saved name opens Home on launch', (tester) async {
    await tester.pumpWidget(const TrollyApp(savedName: 'Frankie'));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hello Frankie!'), findsOneWidget);
    expect(find.text('Welcome to'), findsNothing);
  });
}

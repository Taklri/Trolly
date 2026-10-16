import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trolly/globs/activeuser.dart';
import 'package:trolly/main.dart';
import 'package:trolly/screens/home.dart';

void main() {
  setUp(() {
    ActiveUser.activeUser = {};
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
}

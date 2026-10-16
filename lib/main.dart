import 'package:flutter/material.dart';
import 'screens/getstarted.dart';
import 'screens/home.dart';

void main() {
  runApp(const TrollyApp());
}

class TrollyApp extends StatelessWidget {
  const TrollyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trolly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routes: {
        '/getstarted': (context) => GetStartedScreen(),
        '/home': (context) => HomeScreen(),
      },
      home: GetStartedScreen(),
    );
  }
}

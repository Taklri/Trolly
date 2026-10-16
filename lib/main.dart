import 'package:flutter/material.dart';

import 'screens/getstarted.dart';
import 'screens/home.dart';
import 'screens/shop.dart';
import 'screens/settings.dart';
import 'screens/startup.dart';

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
        '/shop': (context) => const ShopPlaceholderScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      home: const StartupScreen(),
    );
  }
}

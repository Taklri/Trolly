import 'package:flutter/material.dart';
import 'screens/getstarted.dart';
import 'screens/home.dart';
import 'screens/add_product.dart';
import 'screens/edit_product.dart';
import 'screens/shopping.dart';
import 'screens/shopping_method.dart';
import 'screens/shopping_summary.dart';

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
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      routes: {
        '/getstarted': (context) => GetStartedScreen(),
        '/home': (context) => HomeScreen(),
        '/on-the-go': (context) => ShoppingMethodScreen(),
        '/shopping': (context) => ShoppingScreen(),
        '/add-product': (context) => AddProductScreen(),
        '/edit-product': (context) => EditProductScreen(),
        '/shopping-summary': (context) => ShoppingSummaryScreen(),
      },
      home: GetStartedScreen(),
    );
  }
}

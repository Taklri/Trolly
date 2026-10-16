import 'package:flutter/material.dart';
import '../globs/activeuser.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello ${ActiveUser.activeUser["fullname"]}!',
              style: TextStyle(fontSize: 24),
            ),
            Text('Ready to shop?'),
          ],
        ),
      ),
    );
  }
}

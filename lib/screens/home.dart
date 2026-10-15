import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $userName!',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ready to shop?',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'Your Trolly home is ready.',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

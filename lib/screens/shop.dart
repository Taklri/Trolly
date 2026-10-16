import 'package:flutter/material.dart';

class ShopPlaceholderScreen extends StatelessWidget {
  const ShopPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(child: Text('Shopping flow coming soon.')),
    );
  }
}

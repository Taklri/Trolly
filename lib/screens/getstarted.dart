import 'package:flutter/material.dart';

class Getstarted extends StatefulWidget {
  const Getstarted({super.key});

  @override
  State<Getstarted> createState() => _Getstarted();
}

class _Getstarted extends State<Getstarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Text("Hello World")
        ],
      )),
    );
  }
}
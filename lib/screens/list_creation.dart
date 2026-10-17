import 'package:flutter/material.dart';

class ListCreationScreen extends StatelessWidget {
  const ListCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                key: const Key('list-creation-back-button'),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, size: 24),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Text(
                  'List Creation',
                  style: TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

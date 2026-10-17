import 'package:flutter/material.dart';

import '../globs/activeuser.dart';
import '../services/user_preferences.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({
    super.key,
    this.userPreferences = const UserPreferences(),
  });

  final UserPreferences userPreferences;

  @override
  State<GetStartedScreen> createState() => GetStartedPage();
}

class GetStartedPage extends State<GetStartedScreen> {
  final TextEditingController nameController = TextEditingController();
  String err = '';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  String lettersOnly(String value) {
    String letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
    String newValue = '';

    for (int i = 0; i < value.length; i++) {
      if (letters.contains(value[i]) && newValue.length < 10) {
        newValue += value[i];
      }
    }

    return newValue;
  }

  void nameChanged(String value) {
    String newValue = lettersOnly(value);

    if (nameController.text != newValue) {
      nameController.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }

    if (err.isNotEmpty) setState(() => err = '');
  }

  Future<void> getStarted() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        err = 'Please enter your name.';
      });
      return;
    } else if (name.length < 2) {
      setState(() {
        err = 'Name must have at least 2 letters.';
      });
      return;
    }

    await widget.userPreferences.saveName(name);
    if (!mounted) return;

    ActiveUser.activeUser = {'fullname': name};
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
            child: SizedBox(
              width: 350,
              child: Column(
                children: [
                  Spacer(flex: 3),
                  Flexible(
                    flex: 4,
                    child: Image.asset('assets/images/trolly.jpg', width: 350),
                  ),
                  const SizedBox(height: 16),
                  const Text('Welcome to', style: TextStyle(fontSize: 22)),
                  Text(
                    'TROLLY',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Tell us your name:',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 70,
                    child: TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      maxLength: 10,
                      onChanged: nameChanged,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                      ),
                    ),
                  ),
                  if (err.isNotEmpty)
                    Text(
                      err,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        getStarted();
                      },
                      child: Text(
                        "Let's Get Started",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

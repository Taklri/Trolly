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
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ';
    var newValue = '';

    for (var i = 0; i < value.length; i++) {
      if (letters.contains(value[i]) && newValue.length < 10) {
        newValue += value[i];
      }
    }

    return newValue;
  }

  void nameChanged(String value) {
    final newValue = lettersOnly(value);

    if (nameController.text != newValue) {
      nameController.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }

    if (err.isNotEmpty) {
      setState(() {
        err = '';
      });
    }
  }

  Future<void> getStarted() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        err = 'Please enter your name.';
      });
      return;
    }

    if (name.length < 2) {
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
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: SizedBox(
              width: 300,
              child: Column(
                children: [
                  Spacer(flex: 3),
                  Flexible(
                    flex: 4,
                    child: Image.asset('assets/images/trolly.jpg', width: 300),
                  ),
                  SizedBox(height: 16),
                  Text('Welcome to', style: TextStyle(fontSize: 12)),
                  Text(
                    'TROLLY',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text('Tell us your name:', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 44,
                    child: TextField(
                      controller: nameController,
                      maxLength: 10,
                      onChanged: nameChanged,
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                      ),
                    ),
                  ),
                  if (err.isNotEmpty)
                    Text(
                      err,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  Spacer(flex: 2),
                  SizedBox(
                    width: 300,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        getStarted();
                      },
                      child: Text(
                        "Let's Get Started",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

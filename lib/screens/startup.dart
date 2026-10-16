import 'package:flutter/material.dart';

import '../globs/activeuser.dart';
import '../services/user_preferences.dart';
import 'getstarted.dart';
import 'home.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({
    super.key,
    this.userPreferences = const UserPreferences(),
  });

  final UserPreferences userPreferences;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  late final Future<String?> _savedName;

  @override
  void initState() {
    super.initState();
    _savedName = widget.userPreferences.readName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _savedName,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return GetStartedScreen(userPreferences: widget.userPreferences);
        }

        final name = snapshot.data;
        if (name == null || name.isEmpty) {
          return GetStartedScreen(userPreferences: widget.userPreferences);
        }

        ActiveUser.activeUser = {'fullname': name};
        return HomeScreen(userPreferences: widget.userPreferences);
      },
    );
  }
}

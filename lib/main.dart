import 'package:flutter/material.dart';

import 'screens/getstarted.dart';
import 'screens/home.dart';
import 'services/user_preferences.dart';
import 'theme/trolly_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const userPreferences = UserPreferences();
  final savedName = await userPreferences.readName();

  runApp(TrollyApp(savedName: savedName, userPreferences: userPreferences));
}

class TrollyApp extends StatelessWidget {
  const TrollyApp({
    super.key,
    this.savedName,
    this.userPreferences = const UserPreferences(),
  });

  final String? savedName;
  final UserPreferences userPreferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trolly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kTrollyGreen),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: savedName == null
          ? GetStartedScreen(userPreferences: userPreferences)
          : HomeScreen(userName: savedName!),
    );
  }
}

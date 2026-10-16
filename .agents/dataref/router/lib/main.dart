import 'package:flutter/material.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/profile.dart';
import './screens/contact.dart';
import './screens/aboutme.dart';
import './screens/watchlist.dart';
import './screens/deets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      routes: {
        "/home": (context) => HomePage(),
        "/register": (context) => RegisterState(),
        "/login": (context) => LoginState(),
        "/profile": (context) => ProfilePage(),
        "/contact": (context) => ContactPage(),
        "/aboutme": (context) => AboutmePage(),
        "/watch-list": (context) => WatchListPage(),
        "/moviedetails": (context) => DeetsPage(),
      },
      home: RegisterState(),
    );
  }
}

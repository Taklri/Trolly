import 'package:flutter/material.dart';
import 'package:router/globs/activeuser.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logOut(context) {
    ActiveUser.activeUser = {};
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home Page"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("INF232_FINALS_EXAM_IGNACIO_FRANKIE_hRisdhweY2sNsm2Hsgj232"),
            Text("Full name: ${ActiveUser.activeUser["fullname"]}"),
            Text("Username: ${ActiveUser.activeUser["username"]}"),
            Text("Email: ${ActiveUser.activeUser["email"]}"),
            Text(
              "Favorite Movie Genre: ${ActiveUser.activeUser["favorite_movie_genre"]}",
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/watch-list");
              },
              child: Text("Open Watch List"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/profile");
              },
              child: Text("Open Profile Page"),
            ),
            ElevatedButton(
              onPressed: () {
                logOut(context);
              },
              child: Text("LOGOUT"),
            ),
          ],
        ),
      ),
    );
  }
}

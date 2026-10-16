import 'package:flutter/material.dart';
import 'package:router/globs/activeuser.dart';

class DeetsPage extends StatelessWidget {
  const DeetsPage({super.key});

  void logOut(context) {
    ActiveUser.activeUser = {};
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> payloadData =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // print(payloadData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Movie Details"),
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
          ],
        ),
      ),
    );
  }
}

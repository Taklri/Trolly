import 'package:flutter/material.dart';
import 'package:router/globs/activeuser.dart';

class WatchListPage extends StatelessWidget {
  const WatchListPage({super.key});

  void logOut(context) {
    ActiveUser.activeUser = {};
    Navigator.pushReplacementNamed(context, "/login");
  }

  Widget movieCard(title, genre, desc, status, icon, likes, color, context) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Title: $title"),
          Text("Genre: $genre"),
          Text("desc: $desc"),
          Text("status: $status"),
          Icon(icon, size: 100),
          Text("Likes: $likes"),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/moviedetails",
                arguments: {title, genre, desc, status, icon, likes, color},
              );
            },
            child: Text("View $title"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Watch List"),
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

            Column(
              children: [
                // First Movie
                SizedBox(
                  child: Column(
                    children: [
                      movieCard(
                        "007",
                        "Action",
                        "James Bond is a fictional character created by British novelist Ian Fleming in 1953. A British secret agent working for MI6 under the codename 007, Bond has been portrayed on film in twenty-seven productions by actors Sean Connery, David Niven, George Lazenby, Roger Moore, Timothy Dalton, Pierce Brosnan, and Daniel Craig. Eon Productions, which now holds the adaptation rights to all of Fleming's Bond novels, made all but two entries in the film series.",
                        "Showing",
                        Icons.abc,
                        "10",
                        Colors.red,
                        context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

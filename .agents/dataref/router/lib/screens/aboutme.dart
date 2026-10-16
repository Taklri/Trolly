import 'package:flutter/material.dart';
import 'package:router/globs/activeuser.dart';

class AboutmePage extends StatelessWidget {
  const AboutmePage({super.key});

  void logOut(context) {
    ActiveUser.activeUser = {};
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("About Me Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text("INF232_vRsp_IGNACIO_FRANKIE_hgyStps2smxl7Ls232"),
            Text("User name: ${ActiveUser.activeUser["username"]}"),
            Text("Bionote: ${ActiveUser.activeUser["bionote"]}"),
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

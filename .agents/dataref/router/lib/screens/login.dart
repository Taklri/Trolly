import 'package:flutter/material.dart';
import 'package:router/globs/allusers2.dart';
import 'package:router/globs/activeuser.dart';

class LoginState extends StatefulWidget {
  const LoginState({super.key});
  @override
  State<LoginState> createState() => LoginPage();
}

class LoginPage extends State<LoginState> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String err = "";

  void loginAccount() {
    for (int i = 0; i < AllUsers.allUsersList.length; i++) {
      if (usernameController.text == AllUsers.allUsersList[i]["username"] &&
          passwordController.text == AllUsers.allUsersList[i]["password"]) {
        ActiveUser.activeUser = AllUsers.allUsersList[i];
        Navigator.pushNamed(context, "/home", arguments: {"sampledata": "wew"});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Login Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text("INF232_FINALS_EXAM_IGNACIO_FRANKIE_hRisdhweY2sNsm2Hsgj232"),
            Text("THIS IS THE LOGIN PAGE"),
            Text(err),
            Text("Enter Username:"),
            TextField(controller: usernameController),
            Text("Enter Password:"),
            TextField(obscureText: true, controller: passwordController),
            ElevatedButton(
              onPressed: () => {loginAccount()},
              child: Text("Login Your Account"),
            ),
          ],
        ),
      ),
    );
  }
}

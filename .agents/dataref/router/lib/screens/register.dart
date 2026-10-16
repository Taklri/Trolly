import 'package:flutter/material.dart';
import 'package:router/globs/allusers2.dart';

// 1st Step: Create a statehandler class
class RegisterState extends StatefulWidget {
  const RegisterState({super.key});

  @override
  State<RegisterState> createState() => RegisterPage();
}

class RegisterPage extends State<RegisterState> {
  // constructor
  String currentFullname = "";
  String currentUsername = "";
  String currentPassword = "";
  String currentConfirmPassword = "";
  String currentEmail = "";
  String currentFavoriteMovieGenre = "";
  String passwordstr = "";
  String passclr = "";
  String err = "";

  bool istaken = false;
  bool isBad = false;
  bool isGood = false;
  bool isVGood = false;

  TextEditingController fullnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  TextEditingController favoritemoviegenre = TextEditingController();

  void showData() {
    setState(() {
      currentUsername = usernameController.text;
      currentPassword = passwordController.text;
      currentEmail = emailController.text;
      currentFavoriteMovieGenre = favoritemoviegenre.text;
    });
  }

  void createAccount() {
    setState(() {
      Map<String, dynamic> newUser = {
        "fullname": fullnameController.text,
        "username": usernameController.text,
        "password": passwordController.text,
        "email": emailController.text,
        "favorite_movie_genre": favoritemoviegenre.text,
      };

      AllUsers.allUsersList.add(newUser);
    });
  }

  void valData() {
    currentUsername = usernameController.text;
    currentPassword = passwordController.text;
    currentConfirmPassword = cpasswordController.text;
    currentFullname = fullnameController.text;
    currentEmail = emailController.text;
    currentFavoriteMovieGenre = favoritemoviegenre.text;

    istaken = false;

    setState(() {
      if (currentUsername.isEmpty ||
          currentPassword.isEmpty ||
          currentEmail.isEmpty ||
          currentConfirmPassword.isEmpty ||
          currentFullname.isEmpty ||
          currentFavoriteMovieGenre.isEmpty) {
        err = "Fill all fields";
      } else if (currentUsername.length < 5) {
        err = "Username must be atleast 3 characters";
      } else if (currentPassword.length < 8) {
        err = "Password must not be less than 8";
      } else if (currentPassword.length > 15) {
        err = "Password can only be up to 15 characters";
      } else if (currentPassword != currentConfirmPassword) {
        err = "Password and Current Password must match";
      } else if (AllUsers.allUsersList.length == 7) {
        err =
            "Account list reached 7 accounts, you cannot add another account.";
      } else {
        for (int i = 0; i < AllUsers.allUsersList.length; i++) {
          if (currentUsername == AllUsers.allUsersList[i]["username"]) {
            istaken = true;
            break;
          }
        }
        if (istaken) {
          err = "Username already taken";
        } else {
          createAccount();
          Navigator.pushNamed(context, "/login");
          print(AllUsers.allUsersList);
        }
      }

      if (currentPassword.length <= 9) {
        isBad = true;
        passwordstr = "Bad";
        passclr = "red";
      } else if (currentPassword.length <= 12) {
        isGood = true;
        passwordstr = "Good";
        passclr = "yellow";
      } else {
        isVGood = true;
        passwordstr = "Very Good";
        passclr = "color: Colors.red";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Register Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text("INF232_FINALS_EXAM_IGNACIO_FRANKIE_hRisdhweY2sNsm2Hsgj232"),
            Text("Register Page", style: TextStyle(fontSize: 30)),
            Text(err, style: TextStyle(color: Colors.red)),
            Text("Enter Full name:"),
            TextField(controller: fullnameController),
            Text("Enter Username:"),
            TextField(controller: usernameController),
            Text("Enter Email:"),
            TextField(controller: emailController),
            Text("Enter Password:"),
            TextField(obscureText: true, controller: passwordController),
            Text("Enter Confirm Password:"),
            TextField(obscureText: true, controller: cpasswordController),
            Text("Enter Favorite Movie Genre:"),
            TextField(controller: favoritemoviegenre),
            ElevatedButton(
              onPressed: () => {valData()},
              child: Text("Register Account"),
            ),
            Text("Your accounts number is ${AllUsers.allUsersList.length}"),
          ],
        ),
      ),
    );
  }
}

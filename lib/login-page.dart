import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basic_pomo_flutter_app/sign-up-page.dart';
import 'package:basic_pomo_flutter_app/pomo-settings-page.dart';
import 'package:basic_pomo_flutter_app/pomo-timer-page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Pomodoro App'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 32
                  ),
                ),
              ],
            ),

            // Email
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  direction: Axis.vertical,
                  children: <Widget> [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 10,
                        left: 20,
                        right: 20
                      ),
                      child: Text(
                        'Email:',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Padding (
                      padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 20,
                          right: 20
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20*2,
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your email',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Password
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  direction: Axis.vertical,
                  children: <Widget> [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 20,
                        right: 20
                      ),
                      child: Text(
                        'Password:',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Padding (
                      padding: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 20,
                          right: 20
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 20*2,
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter your password',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Login Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 20,
                    right: 20
                  ),
                  child: MaterialButton(
                    height: 50,
                    minWidth: 100,
                    textColor: Colors.white,
                    color: Colors.red,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () async {
                      // 1. Get the user's email and password
                      print(emailController.text);
                      print(passwordController.text);
                      // 2. Send this info to firebase to check if this user has registered
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text
                        ).then((result) {
                          // Then collect this user's information from the
                          // Firebase Database and only show the next page
                          // (PomoTimerPage) after the data has been retrieved.
                          FirebaseDatabase.instance.reference().child("users/"+result.user.uid).once()
                            .then((dataRetrieved) {
                              print("Successfully loaded the data.");
                              print(dataRetrieved.value);
                              print("This is the uid:");
                              print(dataRetrieved.value["userID"]);
                              print("done");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PomoTimerPage(userInfo: dataRetrieved.value)),
                              );
                              print("Logged in successfully!");
                              return dataRetrieved.value;
                            }).catchError((error) {
                              print("Failed to load the data.");
                              print(error);
                            });
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                        }
                      }
                    },
                  )
                ),
              ],
            ),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                FlatButton(
                  textColor: Colors.red,
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}

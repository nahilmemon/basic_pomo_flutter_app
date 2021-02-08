import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:basic_pomo_flutter_app/login-page.dart';
import 'package:basic_pomo_flutter_app/pomo-settings-page.dart';
import 'package:basic_pomo_flutter_app/pomo-timer-page.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
                  'Sign Up',
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

            // Sign Up Button
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
                      'Sign Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () async {
                      // 1. Get the user's email and password
                      print(emailController.text);
                      print(passwordController.text);
                      // 2. Send this info to firebase and register this user.
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text
                        ).then((result) {
                          // Then create default data for this user to store in
                          // Firebase Database and only show the next page
                          // (PomoSettingsPage) after the data has been sent.
                          var userInfo = {
                            "email": emailController.text,
                            "userID": result.user.uid,
                            "pomoDuration": 25,
                            "breakDuration": 5,
                            "dailyGoal": 8
                          };
                          FirebaseDatabase.instance.reference().child("users/"+result.user.uid).set(userInfo);
                          print("Database addition successful.");
                          return userInfo;
                        }).then((userData) {
                          print("This is the uid:");
                          print(userData["userID"]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PomoSettingsPage(userInfo: userData)),
                          );
                          print("Signed up successfully!");
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          print("Failed to sign up T_T");
                          print('The password provided is too weak.');
                        } else if (e.code == 'email-already-in-use') {
                          print("Failed to sign up T_T");
                          print('The account already exists for that email.');
                        }
                      } catch (e) {
                        print("Failed to sign up T_T");
                        print(e);
                      }
                    },
                  )
                ),
              ],
            ),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                FlatButton(
                  textColor: Colors.red,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
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

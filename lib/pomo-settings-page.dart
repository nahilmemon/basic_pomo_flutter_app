import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:basic_pomo_flutter_app/login-page.dart';
import 'package:basic_pomo_flutter_app/pomo-timer-page.dart';

class PomoSettingsPage extends StatefulWidget {
  // final String pathForUserData;
  var userInfo;

  PomoSettingsPage({ Key key, this.userInfo }): super(key: key);

  @override
  _PomoSettingsPageState createState() => _PomoSettingsPageState();
}

class _PomoSettingsPageState extends State<PomoSettingsPage> {
  // Default settings
  var newPomoDuration = 25;
  var newBreakDuration = 5;
  var newDailyGoal = 8;

  double _currentSliderValue = 25;
  double _currentSliderValue2 = 5;
  double _currentSliderValue3 = 8;

  _PomoSettingsPageState() {
    // Load settings from the Firebase database and display them
    refreshSettings();
  }

  void refreshSettings() {
    print("I'm in the settings and refreshing them.");
    var userID = FirebaseAuth.instance.currentUser.uid;

    // Load settings from the Firebase database
    FirebaseDatabase.instance.reference().child("users/"+userID).once()
      .then((dataRetrieved) {
        print("Successfully loaded the data.");
        print(dataRetrieved.value);

        // Then update the sliders on the page according the database info
        newPomoDuration = dataRetrieved.value['pomoDuration'];
        newBreakDuration = dataRetrieved.value['breakDuration'];
        newDailyGoal = dataRetrieved.value['dailyGoal'];

        setState(() {
          _currentSliderValue = newPomoDuration.toDouble();
          _currentSliderValue2 = newBreakDuration.toDouble();
          _currentSliderValue3 = newDailyGoal.toDouble();
        });
      }).catchError((error) {
        print("Failed to load the data.");
        print(error);
      });
  }

  // Collect user input data and send this to the Firebase database
  void updateSettings() {
    print("I'm in the settings and updating them.");
    var userID = FirebaseAuth.instance.currentUser.uid;

    // First get current user data
    FirebaseDatabase.instance.reference().child("users/"+userID).once()
      .then((dataRetrieved) {
        print("Successfully loaded the data.");
        print(dataRetrieved.value);

        var newUserData = {
          "pomoDuration": newPomoDuration,
          "breakDuration": newBreakDuration,
          "dailyGoal": newDailyGoal,
          "userID": dataRetrieved.value["userID"],
          "email": dataRetrieved.value["email"],
        };

        // Then update the database with the old data and the new settings given
        FirebaseDatabase.instance.reference().child("users/"+userID).set(newUserData)
          .then((value) {
            print("Successfully updated the database with the settings given.");
        }).catchError((error) {
          print("Failed to update the database with the settings given.");
          print(error);
        });
      }).catchError((error) {
        print("Failed to load the data.");
        print(error);
      });
  }

  // Reset settings to their default values (in the app and in the database)
  void resetSettings() {
    print("I'm in the settings and resetting them.");
    var userID = FirebaseAuth.instance.currentUser.uid;

    // First get current user data
    FirebaseDatabase.instance.reference().child("users/"+userID).once()
        .then((dataRetrieved) {
      print("Successfully loaded the data.");
      print(dataRetrieved.value);

      // Then reset the data back to default values
      newPomoDuration = 25;
      newBreakDuration = 5;
      newDailyGoal = 8;

      var newUserData = {
        "pomoDuration": newPomoDuration,
        "breakDuration": newBreakDuration,
        "dailyGoal": newDailyGoal,
        "userID": dataRetrieved.value["userID"],
        "email": dataRetrieved.value["email"],
      };

      // Then update the database with the old data and the new settings given
      FirebaseDatabase.instance.reference().child("users/"+userID).set(newUserData)
          .then((value) {
        print("Successfully updated the database with the settings given.");

        setState(() {
          _currentSliderValue = newPomoDuration.toDouble();
          _currentSliderValue2 = newBreakDuration.toDouble();
          _currentSliderValue3 = newDailyGoal.toDouble();
        });
      }).catchError((error) {
        print("Failed to update the database with the settings given.");
        print(error);
      });
    }).catchError((error) {
      print("Failed to load the data.");
      print(error);
    });
  }

  // Log the user out and return back to the login screen
  signOut() async {
    await FirebaseAuth.instance.signOut().then((value) {
      print("Logout successful.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(title: "Basic Pomodoro App")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomo Settings'),
        actions: <Widget>[
          // Pomo Timer Page Button
          IconButton(
            icon: Icon(
              Icons.access_alarm,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PomoTimerPage()),
              );
            },
          ),
          // Settings Page Button
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PomoSettingsPage(userInfo: null)),
              );
            },
          ),
          // Logout Button
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              print("Pressed the logout button.");
              signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            // Pomo Duration
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
                        'Pomo Duration: ${newPomoDuration} minutes',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.red[700],
                        inactiveTrackColor: Colors.red[100],
                        trackShape: RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbColor: Colors.redAccent,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Slider(
                          value: _currentSliderValue,
                          min: 15,
                          max: 60,
                          divisions: 9,
                          label: _currentSliderValue.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue = value;
                              newPomoDuration = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Break Duration
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
                        'Break Duration:  ${newBreakDuration} minutes',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.red[700],
                        inactiveTrackColor: Colors.red[100],
                        trackShape: RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbColor: Colors.redAccent,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Slider(
                          value: _currentSliderValue2,
                          min: 3,
                          max: 15,
                          divisions: 12,
                          label: _currentSliderValue2.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue2 = value;
                              newBreakDuration = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Daily Goal
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
                        'Daily Goal:  ${newDailyGoal} pomos',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.red[700],
                        inactiveTrackColor: Colors.red[100],
                        trackShape: RectangularSliderTrackShape(),
                        trackHeight: 4.0,
                        thumbColor: Colors.redAccent,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Slider(
                          value: _currentSliderValue3,
                          min: 4,
                          max: 20,
                          divisions: 16,
                          label: _currentSliderValue3.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValue3 = value;
                              newDailyGoal = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Update Settings Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                // Update Settings
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
                        'Update Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        updateSettings();
                      },
                    )
                ),
              ],
            ),

            // Refresh Settings Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                // Refresh Settings
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
                        'Refresh Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        refreshSettings();
                      },
                    )
                ),
              ],
            ),

            // Reset Settings Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                // Update Settings
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
                      textColor: Colors.red,
                      color: Colors.white,
                      shape: ContinuousRectangleBorder(
                        side: BorderSide(
                          color: Colors.red,
                          width: 2
                        ),
                      ),
                      child: Text(
                        'Reset Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        resetSettings();
                      },
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

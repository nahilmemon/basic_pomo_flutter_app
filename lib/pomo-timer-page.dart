import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:basic_pomo_flutter_app/login-page.dart';
import 'package:basic_pomo_flutter_app/pomo-settings-page.dart';
// This is a library from pub.dev
import 'package:stop_watch_timer/stop_watch_timer.dart';

class PomoTimerPage extends StatefulWidget {
  // final String pathForUserData;
  var userInfo;

  PomoTimerPage({ Key key, this.userInfo }): super(key: key);

  @override
  _PomoTimerPageState createState() => _PomoTimerPageState();
}

class _PomoTimerPageState extends State<PomoTimerPage> {
  // Default settings
  var newPomoDuration = 25;
  var newBreakDuration = 5;

  // To know which timer duration to show (pomo vs. break time)
  bool shouldIShowPomoTimer = true;

  // Total initial duration of the current timer
  var duration;

  // Create a stopwatch timer
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Update the durations based on which timer is currently active
    updateDurations();

    // _stopWatchTimer.rawTime.listen((value) =>
    //     print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    // _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
    // _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));

  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  // Update the durations based on which timer is currently active
  void updateDurations() {
    if (shouldIShowPomoTimer == true) {
      // duration = newPomoDuration*1000; // seconds for testing/demoing purposes
      duration = newPomoDuration*60*1000; // minutes
      print("Pomo Duration: "+newPomoDuration.toString());
    } else {
      // duration = newBreakDuration*1000; // seconds for testing/demoing purposes
      duration = newBreakDuration*60*1000; // minutes
      print("Break Duration: "+newBreakDuration.toString());
    }
  }

  _PomoTimerPageState() {
    // Load settings from the Firebase database and display them
    refreshSettings();
  }

  // Load settings from the Firebase database and display them
  void refreshSettings() {
    print("I'm in the settings and refreshing them.");
    var userID = FirebaseAuth.instance.currentUser.uid;

    // Load settings from the Firebase database
    FirebaseDatabase.instance.reference().child("users/"+userID).once()
        .then((dataRetrieved) {
      print("Successfully loaded the data.");
      print(dataRetrieved.value);

      // Then update the timers and durations shown on the page
      newPomoDuration = dataRetrieved.value['pomoDuration'];
      newBreakDuration = dataRetrieved.value['breakDuration'];

      updateDurations();

      setState(() {

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
        title: Text('Pomo Timer'),
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
                MaterialPageRoute(builder: (context) => PomoTimerPage(userInfo: null)),
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
              // Turn of the timer first
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              // Then navigate to the settings page
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
              // Turn of the timer first
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              // Then logout
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
            // Count Down Timer
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  var value = snap.data;
                  var remainingTime = duration - value;
                  print("snap");
                  print(duration - value);
                  var displayTime;
                  // Check if a timer has finished
                  if (remainingTime <= 0) {
                    if (shouldIShowPomoTimer == true) {
                      // Pomo finished, so now let's show the break timer
                      shouldIShowPomoTimer = false;
                      updateDurations();
                      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                      print("Break time");
                      // Start the break timer immediately
                      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                    } else {
                      // Break finished, so now let's show the pomo timer
                      shouldIShowPomoTimer = true;
                      updateDurations();
                      // Don't start the next pomo immediately
                      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                      print("Work time");
                    }
                    // value = 0;
                    remainingTime = duration - value;
                    displayTime = StopWatchTimer.getDisplayTime(remainingTime, hours: false, milliSecond: false);
                  } else {
                    // Pomo or break are still running
                    displayTime = StopWatchTimer.getDisplayTime(remainingTime, hours: false, milliSecond: false);
                  }

                  return Column(
                    children: <Widget>[
                      // Pomo Timer Label (only show if the pomo timer is on)
                      Visibility(
                        visible: shouldIShowPomoTimer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            Column(
                              children: <Widget> [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 10,
                                      left: 20,
                                      right: 20
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Work Time Remaining:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Break Timer Label (only show if the break timer is on)
                      Visibility(
                        visible: !shouldIShowPomoTimer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            Column(
                              children: <Widget> [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 10,
                                      left: 20,
                                      right: 20
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Break Time Remaining:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Count down timer
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                          alignment: Alignment.center,
                            child: Text(
                              displayTime,
                              style: const TextStyle(
                                  fontSize: 64,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Start Pomo Button
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
                        'Start Pomo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                      },
                    )
                ),
              ],
            ),

            // Pause Pomo Button
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
                        'Pause Pomo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                      },
                    )
                ),
              ],
            ),

            // Cancel Pomo Button
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
                        'Cancel Pomo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () {
                        // If the pomo timer was on and cancelled, then reset
                        // to the pomo timer's duration
                        if (shouldIShowPomoTimer == true) {
                          _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        } else {
                          // Else if the break timer was on and cancelled, then
                          // reset to the pomo timer's duration instead of the
                          // break timer's duration
                          shouldIShowPomoTimer = true;
                          updateDurations();
                          _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        }
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

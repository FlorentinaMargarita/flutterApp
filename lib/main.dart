import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:ui';
import 'user_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // var initializationSettingsAndroid =
  //     AndroidInitializationSettings('codex_logo');
  // var initializationSettings = InitializationSettings();
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: (String payload) async {
  //   if (payload != null) {
  //     debugPrint('notification payload: ' + payload);
  //   }
  // });
  await UserPreferences().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Epap App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  DateTime selectedDate = DateTime.now();

  final myController = TextEditingController();
  int counter = 0;
  String data;
  String dropdownValue = 'When should we remind you?';
  var listOne = [];

  getStringValuesSF() async {
    SharedPreferences value = await SharedPreferences.getInstance();
    String stringValue = value.getString(data);
    return stringValue;
  }

  _showTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        helpText: "Pick a date, when we should remind you.",
        cancelText: "Cancel",
        confirmText: "Remind Me Epap!");
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  void initState() {
    super.initState();
    data = UserPreferences().data;
    new AndroidInitializationSettings('app_icon');
    var androidInitilize =
        new AndroidInitializationSettings('assets/epap_icon2.png');
    var iOSInitilize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSInitilize);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Receipt Reminder Menu",
              style: TextStyle(color: Colors.greenAccent)),
          leading: Icon(Icons.account_balance_wallet_rounded),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home_outlined),
              onPressed: _launchURL,
            )
          ],
        ),
        body: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(1.0),
              child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.access_alarms),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    hintText: 'Enter an EPAP-reminder',
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 5.0),
                  ),
                  onSubmitted: (String value) async {
                    UserPreferences().data = myController.text;
                    setState(() {
                      data = UserPreferences().data;
                      listOne.add(data);
                      myController.clear();
                    });
                  }),
            ),
            Text(listOne.join(", ")),
            //
            Padding(
              padding: EdgeInsets.all(1.0),
              child: new Container(
                color: Colors.grey[20],
                height: 200,
                width: 200,
                child: new Image.network(
                  'https://is5-ssl.mzstatic.com/image/thumb/Purple124/v4/42/d0/20/42d02062-d787-6c49-d74f-a9f3ee7ea160/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png',
                ),
              ),
            ),
            // RaisedButton(
            //   child: Text("What are my current reminders?"),
            //   onPressed: _showNotification,
            // ),
            RaisedButton(
              child: Text('What are my current reminders?'),
              onPressed: () async {
                await _getActiveNotifications();
              },
            ),
            RaisedButton(
                child: Text("Cancel notification"),
                onPressed: () {
                  setState(() {
                    listOne = [];
                    data = ' ';
                  });
                }),
            // RaisedButton(
            //     child: Text(
            //       "Pick a Date",
            //     ),
            //     onPressed: () => _selectDate(context)),

            RaisedButton(
              child: Text('Repeat notification every minute'),
              onPressed: () async {
                await _repeatNotification();
              },
            ),

            RaisedButton(
              onPressed: () async {
                await flutterLocalNotificationsPlugin.zonedSchedule(
                    0,
                    data,
                    _selectDate(context),
                    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                    const NotificationDetails(
                        android: AndroidNotificationDetails(
                            'full screen channel id',
                            'full screen channel name',
                            'full screen channel description',
                            priority: Priority.high,
                            importance: Importance.high,
                            fullScreenIntent: true)),
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime);

                Navigator.pop(context);
              },
              child: const Text('Pick date'),
            ),
            RaisedButton(
              onPressed: () async {
                await flutterLocalNotificationsPlugin.zonedSchedule(
                    0,
                    data,
                    _showTime(context),
                    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                    const NotificationDetails(
                        android: AndroidNotificationDetails(
                            'full screen channel id',
                            'full screen channel name',
                            'full screen channel description',
                            priority: Priority.high,
                            importance: Importance.high,
                            fullScreenIntent: true)),
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime);

                Navigator.pop(context);
              },
              child: const Text('Remind me daily'),
            ),
            DropdownButton(
              icon: Icon(Icons.alarm_add_outlined),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>['Daily', 'On a specific date', 'Every Hour']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  // value: dropdownValue,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        )));
  }

  Future<void> _repeatNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('repeating channel id',
            'repeating channel name', 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        listOne[1],
        listOne.join(" ,"),
        RepeatInterval.everyMinute,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  // Future<void> _scheduleDailyTenAMNotification() async {
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //       0,
  //       'daily scheduled notification title',
  //       'daily scheduled notification body',
  //       _nextInstanceOfTenAM(),
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //             'daily notification channel id',
  //             'daily notification channel name',
  //             'daily notification description'),
  //       ),
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.time);
  // }

  Future notificationSelected(String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(data == ' '
            ? "no reminders"
            : "Your reminder is:  " + myController.text),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://epap.app/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails("ChannelId", "Epap", "mario",
            importance: Importance.max, priority: Priority.high);

    const NotificationDetails firstNotificationPlatformSpecifics =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(1, 'Epap-Client',
        myController.text, firstNotificationPlatformSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'upload',
        'You created a new reminder',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails("ChannelId", "Epap", "e")),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _getActiveNotifications() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(data == ' ' ? "no reminders" : listOne.join(", ")),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
// Future<String> $message;

class SharedPreferences {
  static Future<SharedPreferences> getInstance() {}

  String getString(String s) {}

  void setString(String message, String value) {}

  getInt(String s) {}

  setInt(String s, int counter) {}
}

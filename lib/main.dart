import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:ui';
import 'user_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rxdart/subjects.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: MyHomePage(title: 'Flutter Epap'),
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
  DateTime selectedDate = DateTime.now();

  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  _initializeNotifications() async {
    final NotificationAppLaunchDetails notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    });
  }

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
    final TimeOfDay timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  Future showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails("ChannelId", "Epap", "mario");

    const NotificationDetails firstNotificationPlatformSpecifics =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(1, 'Epap-Client',
        'ich weiss alles', firstNotificationPlatformSpecifics);
  }

  _selectDate(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        helpText: "Pick a date, when we should remind you.",
        cancelText: "Cancel",
        confirmText: "Remind Me Epap!");
    if (datePicked != null && datePicked != selectedDate)
      setState(() {
        selectedDate = datePicked;
        tz.TZDateTime.now(tz.local);
      });
  }

  Future onSelectNotification(String data) async {
    if (UserPreferences().data != null) {
      print('notification payload: ' + UserPreferences().data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Receipt Reminder Menu",
              style: TextStyle(fontWeight: FontWeight.w600)),
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
                padding: EdgeInsets.only(top: 20.0),
                child: TextField(
                    controller: myController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.access_alarms),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      hintText: 'Enter an EPAP-reminder',
                      contentPadding: new EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 5.0),
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
              Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: RaisedButton(
                    color: Colors.lightGreen,
                    padding: const EdgeInsets.all(15.0),
                    textColor: Colors.white,
                    hoverColor: CupertinoColors.activeBlue,
                    child: Text("What are my current reminders?",
                        style: TextStyle(fontSize: 20)),
                    onPressed: () async {
                      await _getActiveNotifications();
                      await _initializeNotifications();
                    }),
              ),
              Container(
                height: 220,
                width: 220,
                child: new Image.network(
                  'https://is5-ssl.mzstatic.com/image/thumb/Purple124/v4/42/d0/20/42d02062-d787-6c49-d74f-a9f3ee7ea160/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png',
                ),
              ),
              RaisedButton(
                color: Colors.lightGreen,
                textColor: Colors.white,
                onPressed: () async {
                  await flutterLocalNotificationsPlugin.zonedSchedule(
                      0,
                      UserPreferences().data,
                      _selectDate(context),
                      tz.TZDateTime.now(tz.local)
                          .add(const Duration(seconds: 5)),
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
                child: const Text('Pick a start date'),
              ),
              RaisedButton(
                color: Colors.lightGreen,
                textColor: Colors.white,
                onPressed: () async {
                  await flutterLocalNotificationsPlugin.zonedSchedule(
                      0,
                      data,
                      _showTime(context),
                      tz.TZDateTime.now(tz.local)
                          .add(const Duration(seconds: 5)),
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
              RaisedButton(
                color: Colors.lightGreen,
                textColor: Colors.white,
                child: Text('Remind me once a week'),
                onPressed: () async {
                  await _repeatNotification(UserPreferences().data);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: RaisedButton(
                    color: Colors.lightGreen,
                    textColor: Colors.black,
                    child: Text("Cancel notification"),
                    onPressed: () {
                      setState(() {
                        listOne = [];
                        data = ' ';
                      });
                    }),
              ),
            ])));
  }

  Future<void> _repeatNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('repeating channel id',
            'repeating channel name', 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        listOne[1],
        UserPreferences().data,
        RepeatInterval.everyMinute,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

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

  Future<void> _getActiveNotifications() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(data == '' ? "no reminders" : listOne.join(", ")),
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

class SharedPreferences {
  static Future<SharedPreferences> getInstance() {}

  String getString(String s) {}

  void setString(String message, String value) {}

  getInt(String s) {}

  setInt(String s, int counter) {}
}

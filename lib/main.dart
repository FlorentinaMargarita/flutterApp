import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';
import 'dart:ui';
import 'dart:io';

void main() {
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

  getStringValuesSF() async {
    SharedPreferences value = await SharedPreferences.getInstance();
    String stringValue = value.getString(myController.text);
    return stringValue;
  }

  removeValues() async {
    SharedPreferences value = await SharedPreferences.getInstance();
    //Remove String
    value.remove();
  }

  // deleteMessage() async {
  // SharedPreferences preferences = await SharedPreferences.getInstance();
  //     preferences.clear();
  // }

  //   deleteMessage() async {}
  // SharedPreferences value = await SharedPreferences.getInstance();
  // await stringValue.clear();
  // }
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

  // async {
  // final prefs = await SharedPreferences.getInstance();
  // value = prefs.getString('value') ?? ' ';

  @override
  void initState() {
    super.initState();
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
              icon: Icon(Icons.refresh),
              onPressed: () {},
            )
          ],
        ),
        body: Center(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: EdgeInsets.all(10.0),
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
                    await showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text('Remember!'),
                              content:
                                  Text('Do not forget to' + myController.text));
                        });
                  }),
            ),
            // key: 1,
            RaisedButton(
                child: Text('Change Data'), onPressed: () => {counter++}
                // return showDialog(
                //   context: context,
                //   builder: (context) {
                //     return AlertDialog(
                //       content: Text(myController.text),
                //     );

                ),
            // }),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: new Container(
                color: Colors.grey[20],
                height: 200,
                width: 200,
                child: new Image.network(
                  'https://is5-ssl.mzstatic.com/image/thumb/Purple124/v4/42/d0/20/42d02062-d787-6c49-d74f-a9f3ee7ea160/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png',
                ),
              ),
            ),
            RaisedButton(
              child: Text("What are my current reminders?"),
              onPressed: _showNotification,
            ),
            Padding(padding: EdgeInsets.all(1.0), child: TextField()),
            RaisedButton(
              child: Text('Get active notifications'),
              onPressed: () async {
                await _getActiveNotifications();
              },
            ),
            RaisedButton(
              child: Text("Cancel notification"),
              onPressed: () => removeValues(),
              // onPressed: () async {
              //   await _cancelAllNotifications();
              //                 }
            ),
            RaisedButton(
                child: Text(
                  "Pick a Date",
                ),
                onPressed: () => _selectDate(context)),
          ]),
        ));
  }

  // addStringToSF() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.getString(prefs);
  // }
  // getStringValuesSF() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //Return String
  //   String stringValue = prefs.getString('$value');
  //   return stringValue;
  // }

  Future notificationSelected(String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Your reminder is: " + myController.text),
      ),
    );
  }

  Future _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails("ChannelId", "Epap", "mario",
            importance: Importance.max, priority: Priority.high);

    const NotificationDetails firstNotificationPlatformSpecifics =
        NotificationDetails(android: androidDetails);
    // const message = '$value';
    await flutterLocalNotificationsPlugin.show(1, 'Epap-Client',
        myController.text, firstNotificationPlatformSpecifics);

    flutterLocalNotificationsPlugin.zonedSchedule(
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

  // _incrementCounter() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int counter = (prefs.getInt('counter') ?? 0) + 1;
  //   // print('Pressed $counter times.');
  //   await prefs.setInt('counter', counter);
  // }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _getActiveNotifications() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(myController.text),
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

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
Future<String> $message;

class SharedPreferences {
  static Future<SharedPreferences> getInstance() {}

  String getString(String s) {}

  void setString(String message, String value) {}

  getInt(String s) {}

  setInt(String s, int counter) {}
}

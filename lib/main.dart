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
  // final int id;
  // final String title;
  // final String body;
  // final String payload;
  // // _MyHomePageState({this.id, this.body, this.payload, this.title})

  // final rxSub.BehaviorSubject<_MyHomePageState>
  //     didReceiveLocalNotificationSubject =
  //     rxSub.BehaviorSubject<_MyHomePageState>();
  // final rxSub.BehaviorSubject<String> selectNotificationSubject =
  //     rxSub.BehaviorSubject<String>();

  DateTime selectedDate = DateTime.now();

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

  Future _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails("ChannelId", "Epap", "mario",
            importance: Importance.max, priority: Priority.high);
    // var iosDetails = new IOSNotificationDetails();
    // var generalNotificationDetails =
    //     NotificationDetails(android: androidDetails, iOS: iosDetails);
    const NotificationDetails firstNotificationPlatformSpecifics =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        1,
        'Epap-Client',
        'Always remember to upload your receipts...',
        firstNotificationPlatformSpecifics);

//hier koennte ich dann statt seconds days schreiben

    // var scheduleTime = DateTime.now().add(Duration(seconds: 3));

//DIE KRUX IST HIER BEIM SCHEDULING!

    flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'upload',
        'You created a new reminder',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                "ChannelId", "Epap", "Remember to upload your receipts!")),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  // var wart = {print("Hello " + stdin.readLineSync())};

  void write() {
    print("What's your name? ");
    var name = stdin.readLineSync();
    print("Hi, $name!");
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
          child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center, MainAxisAlignment,start
              children: [
                // Padding(
                //   padding: EdgeInsets.all(10.0),
                //   child: Text(
                //     "Hello Epap-Client !",
                //     style: TextStyle(
                //       fontSize: 24,
                //     ),
                //   ),
                // ),
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
                  child: Text("What are my current reminder?"),
                  onPressed: _showNotification,
                ),
                Padding(
                    padding: EdgeInsets.all(1.0),
                    // onPressed: write,
                    child: TextField(
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
                                        Text('Do not forget to "$value".'));
                              });
                        })),
                // Image.asset('assets/epap_icon2.png')

                // RaisedButton(
                //   child: Text('Get active notifications'),
                //   onPressed: () async {
                //     await _getActiveNotifications();
                //   },
                // ),
                // RaisedButton(
                //   child: Text("Cancel notification"),
                //   onPressed: () async {
                //     await _cancelNotification();
                //   },
                // ),
                // RaisedButton(
                //   child: Text('Show notification without timestamp'),
                //   onPressed: () async {
                //     await _showNotificationWithoutTimestamp();
                //   },
                // ),
                // RaisedButton(
                //   child: Text('Show notification with custom timestamp'),
                //   onPressed: () async {
                //     await _showNotificationWithCustomTimestamp();
                //   },
                // ),
                RaisedButton(
                    child: Text(
                      "Pick a Date",
                    ),
                    onPressed: () => _selectDate(context)),
              ]),
        ));
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Notification Clicked $payload"),
      ),
    );
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _getActiveNotifications() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text("active notifications: "),
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

  Future<void> _showNotificationWithoutTimestamp() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }

  Future<void> _showNotificationWithCustomTimestamp() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      when: DateTime.now().millisecondsSinceEpoch - 120 * 1000,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item x');
  }
}

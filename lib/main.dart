import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    var androidInitilize = new AndroidInitializationSettings('epap_icon2.png');
    var iOSInitilize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSInitilize);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
  }

  Future _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            "ChannelId", "Epap", "Remember to upload your receipts!",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello Epap-Client!"),
        leading: Icon(Icons.access_alarm),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
          child: Column(
        children: [
          Text(
            "Hello Flutter !",
            style: TextStyle(fontSize: 24),
          ),
          RaisedButton(
              onPressed: _showNotification, child: Text("I want a hamburger"))
        ],
      )
          // child: RaisedButton(
          //     onPressed: _showNotification, child: Text("I want a hamburger")),
          ),
    );
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Notification Clicked $payload"),
      ),
    );
  }
}

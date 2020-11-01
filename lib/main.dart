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
        title: Text("Receipt Reminder",
            style: TextStyle(color: Colors.greenAccent)),
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
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Hello Epap-Client !",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: new Image.network(
              'https://is5-ssl.mzstatic.com/image/thumb/Purple124/v4/42/d0/20/42d02062-d787-6c49-d74f-a9f3ee7ea160/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png',
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: RaisedButton(
                onPressed: _showNotification,
                child: Text("What did I still want to do?")),
            // Image.asset('assets/epap_icon2.png')
          )
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

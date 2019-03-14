import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

void main() => runApp(MyHomePage());


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  @override
  void initState() {    
    super.initState();
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios =IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg){
        print("onLaunch called ${(msg)}");
    }, onResume: (Map<String, dynamic>msg ){
      print("onResume called ${(msg)}");
    }, onMessage: (Map<String, dynamic>msg ){
      print("onMessage called ${(msg)}");
      mymap = msg;
      showNotification(msg);
    });

    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting) {
      print("onIosSettingRegistered");
    });
    firebaseMessaging.getToken().then((token){
      update(token);
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
        "1", "channelName", "channelDescription");
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);

    //key and value
    msg.forEach((k, v) {
      title = k;
      body = v;
      setState(() {});
    });

    await flutterLocalNotificationsPlugin.show(0, "${body.keys}", "${body.values}", platform);
  }

  //fcm-token firebase cloud messagin
  update(String token) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm-token/$token').set({"token": token});
    mytoken = token;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text('Messagin App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                'My Messagin'
              ),
              new Text(
                '$mytoken',
                style: TextStyle(fontSize: 15, 
                color: Colors.blueAccent)                               
              )
            ],
          ),
        ),
      ),
    );
  }
}

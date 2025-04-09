// lib/main.dart (continuing from Stage 3)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling background message: ${message.messageId} -> ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Messaging App',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Firebase Messaging Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging _messaging;
  String _fcmToken = "Retrieving token...";

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging.instance;
    
    // Request notification permission (especially for iOS).
    _messaging.requestPermission();
    
    // Optional: Subscribe to a specific topic.
    _messaging.subscribeToTopic("messaging");

    // Get the FCM token and display it.
    _messaging.getToken().then((token) {
      setState(() {
        _fcmToken = token ?? "No token received";
      });
      print("FCM Token: $token");
    });

    // Listen for foreground messages.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message in foreground: ${message.notification?.body}");
      _showNotificationDialog(message.notification?.title, message.notification?.body);
    });

    // Handle when the app is opened from a notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.data}");
    });
  }

  void _showNotificationDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? "Notification"),
          content: Text(body ?? "No message content"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK")
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text("FCM Token:\n$_fcmToken", textAlign: TextAlign.center),
      ),
    );
  }
}

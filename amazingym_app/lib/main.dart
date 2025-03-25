import 'package:amazingym_app/checkin_customer.dart';
import 'package:amazingym_app/home.dart';
import 'package:amazingym_app/memberships.dart';
import 'package:amazingym_app/login.dart';
import 'package:amazingym_app/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.subscribeToTopic("AmazinGymNotification");
  await NotificationService.instance.initialize();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/memberships': (context) => const MembershipsPage(),
        '/checkin-customers': (context) => CheckinCustomersPage(),
      },
    );
  }
}

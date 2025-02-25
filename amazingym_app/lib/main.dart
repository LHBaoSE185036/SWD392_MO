import 'package:amazingym_app/notification_service.dart';
import 'package:amazingym_app/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:amazingym_app/api_connection/api_connection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.subscribeToTopic("AmazinGymNotification");
  await NotificationService.instance.initialize();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print ("FCM Token: $fcmToken");

  ApiConnection api = ApiConnection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: LoginScreen(), // Start with the login screen
    );
  }
}

// class NavigationBarApp extends StatelessWidget {
//   const NavigationBarApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(useMaterial3: true),
//       home: const NavigationExample(),
//     );
//   }
// }
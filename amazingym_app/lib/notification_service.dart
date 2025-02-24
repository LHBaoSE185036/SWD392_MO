import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool isInitialized = false;

  Future<void> initialize() async {

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    //request permission
    await _requestPermission();

    //setup message handlers
    await setupMessageHandlers();

    //get FCM token
    // final token = await _messaging.getToken();
    // print('FCM token: $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (isInitialized) {
      return;
    }

    //android setup
    const channel = AndroidNotificationChannel(
      'amazingym_channel',
      'AmazinGym Channel',
      description: 'Channel for AmazinGym notifications',
      importance: Importance.max,
    );

    await _localNotifications
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    //ios setup
    final initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        print('Received local notification');
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    //flutter notification setup
    await _localNotifications.initialize(
      initializationSettings, 
      onDidReceiveBackgroundNotificationResponse: (details) {
      print('Received background notification');
      },
    );

    isInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: AndroidNotificationDetails(
            'amazingym_channel',
            'AmazinGym Channel',
            channelDescription: 'Channel for AmazinGym notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> setupMessageHandlers() async {

    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    //background message
    FirebaseMessaging.onMessageOpenedApp.listen((_handleBackgroundMessage));

    //opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      //open chat screen
    }
  }


}
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/models/custom_notification.dart';
import 'package:notifications/services/notification_service.dart';

import '../routes.dart';

class FirebaseMessagingService {
  final NotificationService notificationService;

  FirebaseMessagingService(this.notificationService);

  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            badge: true, sound: true, alert: true);

    getDeviceFirebaseToken();
    _onMessage();
    _onMessageOpenedApp();
  }

  void getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();

    debugPrint('=====================================');
    debugPrint('TOKEN: $token');
    debugPrint('=====================================');
  }

  void _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        notificationService.showLocalNotification(
          CustomNotification(
              id: android.hashCode,
              title: notification.title!,
              body: notification.body!,
              payload: message.data['route'] ?? ''),
        );
      }
    });
  }

  void _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String route = message.data['route'] ?? '';
    if(route.isNotEmpty) {
      Routes.navigatorKey?.currentState?.pushNamed(route);
    }
  }
}

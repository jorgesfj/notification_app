import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:notifications/routes.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../models/custom_notification.dart';

class NotificationService {

  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidDetails;

  NotificationService() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupAndroidDetails();
    _setupNotifications();
  }

  void _setupAndroidDetails() {
    androidDetails = const AndroidNotificationDetails(
        'lembretes_notifications_details', 'Lembretes',
        channelDescription: 'Este canal é pare lembretes!',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true);
  }

  void _setupNotifications() async {
    await _setupTimezone();
    await _inititalizeNotifications();
  }

  Future<void> _setupTimezone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _inititalizeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await localNotificationsPlugin.initialize(
      const InitializationSettings(android: android),
      onSelectNotification: _onSelectNotification,
    );
  }

  _onSelectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      Navigator.of(Routes.navigatorKey!.currentContext!).pushNamed(payload);
    }
  }

  showNotificationScheduled(
      CustomNotification notification, Duration duration) {
    final date = DateTime.now().add(duration);

    localNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(date, tz.local),
        NotificationDetails(android: androidDetails),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  showLocalNotification(CustomNotification notification) {
    localNotificationsPlugin.show(notification.id, notification.title,
        notification.body, NotificationDetails(android: androidDetails),
        payload: notification.payload);
  }

  checkForNotification() async {
    final details = await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if(details != null && details.didNotificationLaunchApp) {
      _onSelectNotification(details.payload);
    }
  }
}

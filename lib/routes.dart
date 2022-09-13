import 'package:flutter/material.dart';
import 'package:notifications/pages/notification_page.dart';

import 'pages/home_page.dart';

class Routes {

  static Map<String, Widget Function(BuildContext)> list = <String, WidgetBuilder> {
    '/home': (_) => const HomePage(),
    '/notificacao': (_) => const NotificationPage(),
  };

  static String initial = '/home';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();


}
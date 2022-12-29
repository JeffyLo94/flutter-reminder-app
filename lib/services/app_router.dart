import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reminder_app/screens/home_screen.dart';
import 'package:flutter_reminder_app/screens/notification_screen.dart';
import 'package:page_transition/page_transition.dart';

class _AppRoutes {
  const _AppRoutes();
  String get homeScreen => HomePage.route;
  String get notifScreen => NotificationConfirmationScreen.route;
}

class NotifScreenArguments {
  final NotificationResponse payload;

  NotifScreenArguments(this.payload);
}

class AppRouter {
  static _AppRoutes routes = const _AppRoutes();
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      case HomePage.route:
        return PageTransition(
          child: const HomePage(),
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          settings: settings,
        );
      case NotificationConfirmationScreen.route:
        var args = settings.arguments as NotifScreenArguments;
        return PageTransition(
          child: NotificationConfirmationScreen(notifResponse: args.payload),
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          settings: settings,
        );
      default:
        return PageTransition(
          child: const HomePage(),
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          settings: settings,
        );
    }
  }
}

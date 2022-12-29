import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reminder_app/screens/home_screen.dart';
import 'package:flutter_reminder_app/screens/notification_screen.dart';
import 'package:flutter_reminder_app/services/app_router.dart';
import 'package:flutter_reminder_app/services/background_notif.dart';
import 'dart:developer' as logDev;

import 'package:flutter_reminder_app/services/notif_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService(backgroundResponseHandler: notificationTapBackground);
  await NotificationService.instance.initializePlatformNotifications();
  NotificationAppLaunchDetails? notifLaunchDetails = await NotificationService
      .instance.localNotifications
      .getNotificationAppLaunchDetails();
  NotificationService.instance.setNotifAppLaunchDetails = notifLaunchDetails;
  print('APP INITALIZED');
  logDev.log('Reminder app initialized');
  runApp(MyApp(
    notificationResponse: notifLaunchDetails?.notificationResponse,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    this.notificationResponse,
  }) : super(key: key);
  final NotificationResponse? notificationResponse;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = AppRouter.navigatorKey;
  late Timer? _timerLink;

  NavigatorState? get _navigator => _navigatorKey.currentState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('inactive state');
        break;
      case AppLifecycleState.resumed:
        print('resumed state');
        break;
      case AppLifecycleState.paused:
        print('paused state');
        break;
      case AppLifecycleState.detached:
        print('detached state');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder Scheduler',
      navigatorKey: _navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      home: generateHome(),
      // builder: ((context, child) {}),
      // initialRoute: AppRouter.routes.homeScreen,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const HomePage(),
    );
  }

  Widget generateHome() {
    print('APP GENERATE HOME');

    if (widget.notificationResponse != null) {
      print('WAS FROM BACKGROUND! payload - ${widget.notificationResponse}');
      // _scheduleBackgroundNotifHandler(widget.notificationResponse!);
      return NotificationConfirmationScreen(
          notifResponse: widget.notificationResponse!);
    } else {
      return const HomePage();
    }
  }

  // void _scheduleBackgroundNotifHandler(NotificationResponse payload) {
  //   _timerLink = Timer(const Duration(milliseconds: 300), () {
  //     if (_navigator != null) {
  //       print('MESSAGE*******: NAVIGATING TO notifs!');
  //       _timerLink?.cancel();
  //       _navigator?.pushNamed(AppRouter.routes.notifScreen,
  //           arguments: NotifScreenArguments(payload));
  //       // });
  //     } else {
  //       print('MESSAGE*******: rescheduling timer!');
  //       _timerLink;
  //     }
  //   });
  // }
}

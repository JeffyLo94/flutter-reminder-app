import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reminder_app/main.dart';
import 'package:flutter_reminder_app/services/app_router.dart';
import 'dart:developer' as logDev;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
  if (notificationResponse.payload != null &&
      notificationResponse.payload!.isNotEmpty) {
    print('MESSAGE*******: HANDLING BACKGROUND NOTIF!');
    // START APP HERE - TELL app to navigate to what screen.
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp(
      notificationResponse: notificationResponse,
    ));
  }
}

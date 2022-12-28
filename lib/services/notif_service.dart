import 'dart:io';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_reminder_app/services/download_util.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();
  final text = Platform.isIOS;
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation(
        await FlutterNativeTimezone.getLocalTimezone(),
      ),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: receivedNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    final bigPicture = await DownloadUtil.downloadAndSaveFile(
        "https://thumbs.dreamstime.com/b/reminder-d-rendered-red-tag-banner-isolated-white-background-reminder-tag-banner-112042483.jpg",
        Platform.isIOS ? "reminder.jpg" : "reminder");

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      largeIcon: FilePathAndroidBitmap(bigPicture),
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicture),
        hideExpandedLargeIcon: false,
      ),
      color: const Color(0xff2196f3),
    );

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
            threadIdentifier: "thread1",
            attachments: <DarwinNotificationAttachment>[
          DarwinNotificationAttachment(bigPicture)
        ]);

    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse != null &&
          details.notificationResponse!.payload != null) {
        behaviorSubject.add(details.notificationResponse!.payload!);
      } else {
        print("WARN: Notif missing response!");
      }
    }

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  Future<NotificationDetails> _groupedNotificationDetails() async {
    const List<String> lines = <String>[
      'group 1 First reminder',
      'group 1   Second reminder',
      'group 1   Third reminder',
      'group 2 First reminder',
      'group 2   Second reminder'
    ];
    const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        contentTitle: '5 messages',
        summaryText: 'missed reminders');
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      setAsGroupSummary: true,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      styleInformation: inboxStyleInformation,
      color: Color(0xff2196f3),
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(threadIdentifier: "thread2");

    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse != null &&
          details.notificationResponse!.payload != null) {
        behaviorSubject.add(details.notificationResponse!.payload!);
      } else {
        print("WARN: Notif missing response!");
      }

    }

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  Future<void> showScheduledLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int seconds,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      platformChannelSpecifics,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showPeriodicLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> showGroupedNotifications({
    required String title,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    final groupedPlatformChannelSpecifics = await _groupedNotificationDetails();
    await _localNotifications.show(
      0,
      "group 1",
      "First reminder",
      platformChannelSpecifics,
    );
    await _localNotifications.show(
      1,
      "group 1",
      "Second reminder",
      platformChannelSpecifics,
    );
    await _localNotifications.show(
      3,
      "group 1",
      "Third reminder",
      platformChannelSpecifics,
    );
    await _localNotifications.show(
      4,
      "group 2",
      "First reminder",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await _localNotifications.show(
      5,
      "group 2",
      "Second reminder",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await _localNotifications.show(
      6,
      Platform.isIOS ? "group 2" : "Attention",
      Platform.isIOS ? "Third reminder" : "5 missed reminders",
      groupedPlatformChannelSpecifics,
    );
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    print('id $id');
  }

  void receivedBackgroundNotification(NotificationResponse? payload) {
    print('RECEIVED BACKGROUND NOTIFICATION');
    if (payload != null &&
        payload.payload != null &&
        payload.payload!.isNotEmpty) {
      behaviorSubject.add(payload.payload!);
    }
  }
  void receivedNotification(NotificationResponse? payload) {
    print('RECEIVED NOTIFICATION');
    if (payload != null &&
        payload.payload != null &&
        payload.payload!.isNotEmpty) {
      behaviorSubject.add(payload.payload!);
    }
  }

  void cancelAllNotifications() => _localNotifications.cancelAll();
}

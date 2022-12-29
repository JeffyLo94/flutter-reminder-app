import 'dart:io';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_reminder_app/services/download_util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService(
      {required void Function(NotificationResponse)
          backgroundResponseHandler}) {
    instance.backgroundResponseHandler = backgroundResponseHandler;
    return instance;
  }

  NotificationService._internal();

  // NotificationService({required this.backgroundResponseHandler});
  final text = Platform.isIOS;
  NotificationAppLaunchDetails? _notificationAppLaunchDetails;
  late void Function(NotificationResponse) backgroundResponseHandler;
  static int notifId = 0;
  final BehaviorSubject<NotificationResponse> _behaviorSubject =
      BehaviorSubject();
  final BehaviorSubject<List<PendingNotificationRequest>> pendingNotifsSubject =
      BehaviorSubject();

  final localNotifications = FlutterLocalNotificationsPlugin();
  Future<void> initializePlatformNotifications() async {
    print('INITIALIZED NOTIFICATIONS!');
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

    await localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: receivedNotification,
      onDidReceiveBackgroundNotificationResponse: backgroundResponseHandler,
    );
  }

  ValueStream<NotificationResponse> get notifStream => _behaviorSubject.stream;


  NotificationAppLaunchDetails? get notifAppLaunchDetails =>
      _notificationAppLaunchDetails;
  set setNotifAppLaunchDetails(NotificationAppLaunchDetails? launchDetails) =>
      _notificationAppLaunchDetails = launchDetails;

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

    final details = await localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse != null &&
          details.notificationResponse!.payload != null) {
        _behaviorSubject.add(details.notificationResponse!);
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

    final details = await localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse != null &&
          details.notificationResponse!.payload != null) {
        _behaviorSubject.add(details.notificationResponse!);
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
    await localNotifications.zonedSchedule(
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
    pendingNotifsSubject
        .add(await localNotifications.pendingNotificationRequests());
  }

  // Future<void> scheduleBackgroundNotification({})

  Future<void> showLocalNotification({
    int? id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await localNotifications.show(
      id ?? notifId++,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
    pendingNotifsSubject
        .add(await localNotifications.pendingNotificationRequests());
  }

  Future<void> showPeriodicLocalNotification({
    int? id,
    String? title,
    String? body,
    String? payload,
    RepeatInterval interval = RepeatInterval.everyMinute,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await localNotifications.periodicallyShow(
      id ?? notifId++,
      title,
      body,
      interval,
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
    );
    pendingNotifsSubject
        .add(await localNotifications.pendingNotificationRequests());
  }

  Future<void> showGroupedNotifications({
    required String title,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    final groupedPlatformChannelSpecifics = await _groupedNotificationDetails();
    await localNotifications.show(
      0,
      "group 1",
      "First reminder",
      platformChannelSpecifics,
    );
    await localNotifications.show(
      1,
      "group 1",
      "Second reminder",
      platformChannelSpecifics,
    );
    await localNotifications.show(
      3,
      "group 1",
      "Third reminder",
      platformChannelSpecifics,
    );
    await localNotifications.show(
      4,
      "group 2",
      "First reminder",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await localNotifications.show(
      5,
      "group 2",
      "Second reminder",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await localNotifications.show(
      6,
      Platform.isIOS ? "group 2" : "Attention",
      Platform.isIOS ? "Third reminder" : "5 missed reminders",
      groupedPlatformChannelSpecifics,
    );
    pendingNotifsSubject
        .add(await localNotifications.pendingNotificationRequests());
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    print('id $id');
  }

  // void receivedBackgroundNotification(NotificationResponse? payload) {
  //   print('RECEIVED BACKGROUND NOTIFICATION');
  //   if (payload != null &&
  //       payload.payload != null &&
  //       payload.payload!.isNotEmpty) {
  //     // _updateSubject(payload.payload!);
  //     _behaviorSubject.add(payload.payload!);
  //   }
  //   // backgroundResponseHandler!(payload);
  // }

  void receivedNotification(NotificationResponse? payload) {
    print('RECEIVED NOTIFICATION');
    if (payload != null) {
      _behaviorSubject.add(payload);
    }
  }

  void cancelAllNotifications() => localNotifications.cancelAll();
}

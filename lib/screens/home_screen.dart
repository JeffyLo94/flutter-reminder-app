import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reminder_app/screens/notification_screen.dart';
import 'package:flutter_reminder_app/services/background_notif.dart';
import 'package:flutter_reminder_app/services/notif_service.dart';
import 'package:flutter_reminder_app/widget/info_value_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.title = "Do Something"}) : super(key: key);
  static const String route = '/homeScreen';

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotificationService notificationService;
  late StreamSubscription<NotificationResponse> notifsSub;
  late StreamSubscription<List<PendingNotificationRequest>> pendingNotifsSub;
  final int scheduledTimeSeconds = 30;
  late NotificationAppLaunchDetails? notificationAppLaunchDetails;
  int totalPendingNotifs = 0;

  @override
  void initState() {
    print('INITIALIZING HOME PAGE!');
    notificationService = NotificationService.instance;
    notificationAppLaunchDetails = notificationService.notifAppLaunchDetails;
    listenToNotificationStream();
    listenToPendingNotifsStream();
    super.initState();
  }

  @override
  void dispose() {
    print('Disposing home screen');
    notifsSub.cancel();
    super.dispose();
  }

  void listenToPendingNotifsStream() => pendingNotifsSub =
          notificationService.pendingNotifsSubject.listen((value) {
        print('pending notifs subject was updated');
        setState(() {
          totalPendingNotifs = value.length;
        });
      });

  void listenToNotificationStream() =>
      notifsSub = notificationService.notifStream.distinct().listen(
        (notifResponse) {
          print('Payload is: $notifResponse - NAVIGATING TO Notifs!');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotificationConfirmationScreen(notifResponse: notifResponse),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    var btnHt = MediaQuery.of(context).size.height * 0.1;
    var btnWt = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InfoValueString(
            title: 'Did notification launch app?',
            value: notificationAppLaunchDetails?.didNotificationLaunchApp,
          ),
          if (notificationAppLaunchDetails?.didNotificationLaunchApp ??
              false) ...<Widget>[
            const Text('Launch notification details'),
            InfoValueString(
                title: 'Notification id',
                value: notificationAppLaunchDetails?.notificationResponse?.id),
            InfoValueString(
                title: 'Action id',
                value: notificationAppLaunchDetails
                    ?.notificationResponse?.actionId),
            InfoValueString(
                title: 'Input',
                value:
                    notificationAppLaunchDetails?.notificationResponse?.input),
            InfoValueString(
              title: 'Payload:',
              value:
                  notificationAppLaunchDetails?.notificationResponse?.payload,
            ),
          ],
          InfoValueString(
            title: 'Total Pending Notifications',
            value: totalPendingNotifs,
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.1,
              maxHeight: MediaQuery.of(context).size.height * 0.2,
            ),
            // Update with local image
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
            child: Image.asset("assets/images/dosomething.png", scale: 0.2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: btnHt,
                width: btnWt,
                child: ElevatedButton(
                    onPressed: () async {
                      print('REMINDER NOW PRESSED');
                      await notificationService.showLocalNotification(
                          id: 0,
                          title: "Do Something",
                          body: "Time to do something!",
                          payload: "You just did something! POGGERS!");
                    },
                    child: const Text(
                      "Reminder Now",
                      textAlign: TextAlign.center,
                    )),
              ),
              SizedBox(
                height: btnHt,
                width: btnWt,
                child: ElevatedButton(
                    onPressed: () async {
                      await notificationService.showGroupedNotifications(
                          title: "Do Something");
                    },
                    child: const Text(
                      "Reminder grouped",
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: btnHt,
                width: btnWt,
                child: ElevatedButton(
                    onPressed: () async {
                      print('SCHEDULE REMINDER PRESSED');
                      final snackBar = SnackBar(
                          content: Text(
                              'Scheduled for $scheduledTimeSeconds seconds'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      await notificationService.showScheduledLocalNotification(
                          id: 1,
                          title: "Do Something",
                          body: "Time to do something!",
                          payload: "You just did something! POGGERS!",
                          seconds: scheduledTimeSeconds);
                    },
                    child: Text(
                      "Schedule Reminder ($scheduledTimeSeconds sec)",
                      textAlign: TextAlign.center,
                    )),
              ),
              SizedBox(
                height: btnHt,
                width: btnWt,
                child: ElevatedButton(
                    onPressed: () async {
                      print('SCHEDULE REMINDER PRESSED');
                      const snackBar =
                          SnackBar(content: Text('Scheduled for 300 seconds'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      await notificationService.showScheduledLocalNotification(
                          id: 1,
                          title: "Do Something",
                          body: "Time to do something!",
                          payload: "You just did something! POGGERS!",
                          seconds: 300);
                    },
                    child: const Text(
                      "Schedule Reminder (5 min)",
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: btnHt,
                width: btnWt,
                child: ElevatedButton(
                    onPressed: () async {
                      print('SCHEDULE REMINDER PRESSED');
                      const snackBar =
                          SnackBar(content: Text('Scheduled for every hour'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      await notificationService.showPeriodicLocalNotification(
                          title: "Do Something Every Hour",
                          body: "Time to do something!",
                          payload: "You just did something! POGGERS!",
                          interval: RepeatInterval.hourly);
                    },
                    child: const Text(
                      "Repeat Hourly",
                      textAlign: TextAlign.center,
                    )),
              ),
              SizedBox(
                height: btnHt,
                width: btnWt,
                // alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    print('SCHEDULE REMINDER PRESSED');
                    const snackBar =
                        SnackBar(content: Text('Scheduled for Every Minute'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    await notificationService.showPeriodicLocalNotification(
                        title: "Do Something Every Minute",
                        body: "Time to do something!",
                        payload: "You just did something! POGGERS!",
                        interval: RepeatInterval.everyMinute);
                  },
                  child: const Text(
                    "Repeat Minute Reminders",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                // height: btnHt,
                // width: btnWt,
                // alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    notificationService.cancelAllNotifications();
                  },
                  child: const Text(
                    "Cancel All Reminders",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

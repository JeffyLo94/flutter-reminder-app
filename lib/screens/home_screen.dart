import 'package:flutter/material.dart';
import 'package:flutter_reminder_app/screens/notification_screen.dart';
import 'package:flutter_reminder_app/services/notif_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NotificationService notificationService;
  final int scheduledTimeSeconds = 2;

  @override
  void initState() {
    notificationService = NotificationService();
    listenToNotificationStream();
    notificationService.initializePlatformNotifications();
    super.initState();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NotificationConfirmationScreen(payload: payload)));
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Do Something"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
            // Update with local image
            child: Image.asset("assets/images/dosomething.png", scale: 0.2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                    onPressed: () async {
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
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                    onPressed: () async {
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
                    child: const Text(
                      "Schedule Reminder",
                      textAlign: TextAlign.center,
                    )),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.4,
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.4,
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

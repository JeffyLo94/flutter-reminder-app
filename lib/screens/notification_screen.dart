import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_reminder_app/services/app_router.dart';

class NotificationConfirmationScreen extends StatelessWidget {
  const NotificationConfirmationScreen({
    Key? key,
    required this.notifResponse,
  }) : super(key: key);
  static const String route = '/notifcationScreen';
  final NotificationResponse notifResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Do Something"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: Image.asset(
                "assets/images/dosomething.png",
              ),
            ),
            Text('Notif ID: ${notifResponse.id}'),
            Text('Notif aID: ${notifResponse.actionId}'),
            Text('Notif input: ${notifResponse.input}'),
            Text('Notif response type: ${notifResponse.notificationResponseType}'),
            Text('Payload: ${notifResponse.payload}'),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: ElevatedButton(
                child: Text('Return Home'),
                onPressed: () {
                  print('returning home');
                  Navigator.of(context)
                      .popAndPushNamed(AppRouter.routes.homeScreen);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

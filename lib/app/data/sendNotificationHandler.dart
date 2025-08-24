import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:mindrena/app/modules/splash/controllers/splash_controller.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling background message: ${message.data}");
  // Show the notification manually
  SendNotificationHandler.displayNotification(message);
}

class SendNotificationHandler {
  static String fcmToken = "";
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? serverKeyGG;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "xstore-faa86",
      "private_key_id": "5b5ba86068c3fec52fad25156e2bc037d6cbe0bc",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCbFjDsNxiRKVwY\n+D499A5+DH7/YYENhIsWWomqqeVQvKzre/OaCk+85OkmhyK+v542zFKPuwDiKiHT\nta1uyFXWWPLJqFc1CW9nDhWhz0TIx1gXqmsnT2anXMC1b/piIWb5B/lh7nEMcEfT\nfBOsH2iB5UH5Mq/Q8t1ycn9VUMjPNjXEWM8hh7c5Gct5AmhF+sF0PSaLr9OM/Qe/\nRBQ0j0wPHVsJFfZD0nfdpNfTy6ue+Tqqvif2+nw7qglIb9j08LXk7xkmMnG+Cykj\nQC2fk+oKt4B7dsNULPiU51Sd7ZEtI1hBJrJNclG37tK6gppWT00S9yZEf/jBKdgC\n+lJ3yq7bAgMBAAECggEAJsIQfvA0BQ8zk4/yqjQErS69TGCXSoQN6Iu+7PZht2A3\nzPAgzKX4EIqa1ASgw9AKn8JHfeEr0tnZs1mrmsyZWyTGpGwcQ0Z032nvMQ2mMJFV\nLDDsb5oR2xC8nnt6NS0I2YLLKdTXztZ+tNVE61a8HP5pEvi+ZLdVbYU82lsCnHoZ\ni31ub+iwA3SlNeMhDLo1v3zQdJCD8gi45XviGw4EOOd/50p3TA2MlY4rlY2Pfc5/\n0F1d5/53sO7mDn+6qqy/AoNIv05gZP8uS+2+vwiTU5/AMpPDsMGOsCswCutzxpx+\nz/jBqai309JoahVMkLWse8rMfRtl/Af53R92JHwMpQKBgQDS7zQMBs86vcUu+j8P\nNBIPP6fMHOzAdaeAcTIkdxd2XdShQOH+uycP+tTyOqlEAUIKNHBiszzv/le8byFL\nZZj8uAiKlubsbABH4SR3RP1ouDIKSTeh8a3Y+V9nlKrQldR84RhoUVJQ/kTSvIei\nY9b2KU8r2E7/cWbRNNLNqsHS/QKBgQC8OHdkfzqf+c7YVcZ3lxsaosSSuBV+IlXN\nm0l0JxhsYo0SbKifNQDUrb5Rh4RP2jRsvgc2Hf7PG3cIC82/1Av57W3tJxARaJaE\nFam528ZR/afb3awDq9xv2YXAAPYPN8+QvcYRPZYa7cGJEcvRTR0sTiF7va5tugxR\nhi4ITI0MtwKBgQCt44pJm9d8enMyvhP8KZX1wilHSFUYeCWk6ixHCXJrHwEqCj4E\nbC7QqpygMCHYMR1LIl2/0DkdM9UKP6b37AKJ3AEWlz45ivNUTlNsi5BIowiFmERn\nmcASjcnLrzB+EfaBGGOxo9CzelosTEWYZqwQdI+S+phtVwRG1UAvUmTE1QKBgC9B\nZghfQRLFHz+FWYzQ7UcksoG7ofnHGQ/D+w8keadMnuqPSU6fehPrgyrpATkjKaJb\nm2fk5AKPfLUScZfF3zPifoTaF9inD5Md9TzqhsIzEx/KadOKJJAYZtIr65sqgfxv\nCPlvIu6j3sFRLIDiAX8MJq/wkYiO+2TEcW43+fnFAoGAblamSLVFUqCZXCIgptna\no8rYBvWtbyVsXxUdV1I6rfVDNtTa1rFxSPvcfVH4k93jqbuPTvC5/4/qlVxec9G1\n+Msktj56OM5M9oMQ8PBLf//c88+c1kxrgI2q5CyCYvWgrp6AEwhGLkw/a8eNEeJz\n4Bn6nJL093YqN1R+fYMA+t0=\n-----END PRIVATE KEY-----\n",
      "client_email": "xstore-ecommerce@xstore-faa86.iam.gserviceaccount.com",
      "client_id": "109648593035820004383",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/xstore-ecommerce%40xstore-faa86.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client,
        );

    client.close();
    return credentials.accessToken.data;
  }

  Future<void> getKey() async {
    serverKeyGG = await getAccessToken();
    print(serverKeyGG);
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    Get.put((SplashController()));
    Get.offAllNamed('/splash');
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    await FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        print(message.notification!.title);
        print(message.notification!.body);
        print(message.data);
        // Local Notification Code to Display Alert
        displayNotification(message);

        print('GG');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  static Future<String> getDeviceTokenToSendNotification() async {
    fcmToken = (await FirebaseMessaging.instance.getToken()).toString();
    print("FCM Token: $fcmToken");

    return fcmToken;
  }

  Future<void> initNotification() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Call to initialize push notifications (this part might still be handled via Firebase or another service)
    initPushNotification();
  }

  static void displayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "push_notification_demo",
          "push_notification_demo_channel",
          importance: Importance.max,
          priority: Priority.high,
          icon: 'notilogo',
        ),
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: json.encode(message.data),
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  static void initialized() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notilogo'); // use your custom icon

    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: initializationSettingsAndroid),
      onDidReceiveNotificationResponse: (details) {
        print(details.toString());
        print("localBackgroundHandler :");
        print(
          details.notificationResponseType ==
                  NotificationResponseType.selectedNotification
              ? "selectedNotification"
              : "selectedNotificationAction",
        );
        print(details.payload);

        try {
          json.decode(details.payload ?? "{}") as Map? ?? {};
        } catch (e) {
          print(e);
        }
      },
      onDidReceiveBackgroundNotificationResponse: localBackgroundHandler,
    );
  }

  static Future<void> localBackgroundHandler(NotificationResponse data) async {
    print(data.toString());
    print("localBackgroundHandler :");
    print(
      data.notificationResponseType ==
              NotificationResponseType.selectedNotification
          ? "selectedNotification"
          : "selectedNotificationAction",
    );
    print(data.payload);

    try {
      json.decode(data.payload ?? "{}") as Map? ?? {};
      // openNotification(payloadObj);
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    final Uri url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/xstore-faa86/messages:send',
    );

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKeyGG',
    };

    final Map<String, dynamic> payload = {
      'message': {
        'token': token,
        'notification': {'title': title, 'body': body},
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': 'This is additional data payload',
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Push Notification Sent Successfully!');
      } else {
        print('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending push notification: $e');
    }
  }
}

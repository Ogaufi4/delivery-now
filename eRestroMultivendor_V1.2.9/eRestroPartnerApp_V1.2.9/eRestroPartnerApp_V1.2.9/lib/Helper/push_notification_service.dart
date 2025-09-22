import 'dart:io';

import 'package:project/Helper/api_base_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'session.dart';
import 'string.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

backgroundMessage(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class PushNotificationService {
  late BuildContext context;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  PushNotificationService({required this.context});

//============================= initialise =====================================

  Future initialise() async {
    iOSPermission();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    messaging.getToken().then(
      (token) async {
        print("token:$token");
        if (CUR_USERID != null && CUR_USERID != "") _registerToken(token);
      },
    );

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/notification_icon');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!, context);

            break;
          case NotificationResponseType.selectedNotificationAction:
            print("notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");

            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );

//============================= onMessage ======================================
// when app in foreground (running state) (open)

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        var data = message.data;
        var title = (message.notification != null) ? message.notification!.title.toString() : data['title'].toString();
        var body = (message.notification != null) ? message.notification!.body.toString() : data['body'].toString();
        var type = data['type'] ?? "";
        String? image;

        if (message.notification != null) {
          image = message.notification!.android?.imageUrl ?? message.notification!.apple?.imageUrl;
        }

        image ??= data['image']?.toString() ?? '';

        if (image != "") {
          generateImageNotication(title, body, image, type);
        } else {
          generateSimpleNotication(title, body, type);
        }
      },
    );

//============================= onMessage ======================================
// when app in terminated state

    messaging.getInitialMessage().then(
      (RemoteMessage? message) async {
        bool back = await getPrefrenceBool(iSFROMBACK);
        if (message != null && back) {
          var type = message.data['type'] ?? '';
          if (type == "commission") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(key: navigatorKey),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(key: navigatorKey),
              ),
            );
          }
        }
      },
    );

//========================= onMessageOpenedApp =================================
// when app is background

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        var type = message.data['type'] ?? '';
        if (type == "commission") {
          // try to add login or not condition here.
          // if login then redirect to home scren else login screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(key: navigatorKey),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(key: navigatorKey),
            ),
          );
        }
        setPrefrenceBool(iSFROMBACK, false);
      },
    );
  }

//========================= iOSPermission ======================================

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

//========================= _registerToken =====================================

  void _registerToken(String? token) async {
    var parameter = {
      'user_id': CUR_USERID,
      FCMID: token,
      DEVICETYPE: Platform.isAndroid ? "android" : "ios",
    };
    apiBaseHelper.postAPICall(updateFcmApi, parameter, context).then(
          (getdata) async {},
          onError: (error) {},
        );
  }
}

//========================= myForgroundMessageHandler ==========================
selectNotificationPayload(String? payload, BuildContext context) async {
  if (payload != null) {
    List<String> pay = payload.split(",");

    if (pay[0] == "commission") {
      // try to add login or not condition here.
      // if login then redirect to home scren else login screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(key: navigatorKey),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(key: navigatorKey),
        ),
      );
    }
    setPrefrenceBool(iSFROMBACK, false);
  }
}

/* Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  await setPrefrenceBool(iSFROMBACK, true);

  return Future<void>.value();
} */

@pragma('vm:entry-point')
  Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
    await setPrefrenceBool(iSFROMBACK, true);
    await Firebase.initializeApp();
    //perform any background task if needed here
    if (Platform.isAndroid) {
      if (remoteMessage.notification == null) {
        var data = remoteMessage.data;
        var title = data['title']??"";
        var body = data['body']??"";
        var type = data['type']??"";
        var image = data['image']??"";
        if (image != 'null' && image != '') {
        generateImageNotication(title, body, image, type);
      } else {
        generateSimpleNotication(title, body, type);
      }
      }
    }
  }

//========================= generateSimpleNotication ===========================

Future<void> generateSimpleNotication(String title, String body, String type) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'com.konnect.erestropartner',
    'eKonnect Partner',
    channelDescription: 'eKonnect Partner',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    playSound: true,
    icon: "@drawable/notification_icon",
    sound: RawResourceAndroidNotificationSound('notification'),
  );

  const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(sound: 'notification.aiff');
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: type,
  );
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }


  Future<void> generateImageNotication(String title, String msg, String image, String type) async {
    var largeIconPath = await _downloadAndSaveImage(image, image.split('/').last);
    var bigPicturePath = await _downloadAndSaveImage(image, image.split('/').last);
    var bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('com.konnect.erestropartner', 'eRestro Partner',
      channelDescription: 'eKonnect Partner',
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        styleInformation: bigPictureStyleInformation);
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(sound: 'notification.aiff');
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type);
  }

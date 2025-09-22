import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../Home.dart';
import '../main.dart';
import 'Session.dart';
import 'String.dart';
import 'package:firebase_core/firebase_core.dart';

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
  final BuildContext context;
  final Function? updateHome;

  PushNotificationService({required this.context, this.updateHome});

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
    messaging.getToken().then((token) async {
      CUR_USERID = await getPrefrence(ID);
      if (CUR_USERID != null && CUR_USERID != "") _registerToken(token, context);
    });

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/notification_icon');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    //Android 13 or higher
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled();

    flutterLocalNotificationsPlugin.initialize(
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
    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var data = message.data;
      print("rider:$data");

      /* var title = data.title.toString();
      var body = data.body.toString();
      var image = message.data['image'] ?? '';
      var type = '';
      type = message.data['type'] ?? ''; */
      var title = (message.notification != null) ? message.notification!.title.toString() : data['title'].toString();
      var body = (message.notification != null) ? message.notification!.body.toString() : data['body'].toString();
      var type = data['type']??"";
      /* var image = (message.notification != null)
          ? (message.notification!.android?.imageUrl ?? message.notification!.apple?.imageUrl)
          : data['image'].toString(); */
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
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
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

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _registerToken(String? token, BuildContext context) async {
    var parameter = {USER_ID: CUR_USERID, FCM_ID: token, DEVICETYPE: Platform.isAndroid ? "android" : "ios"};
    apiBaseHelper.postAPICall(updateFcmApi, parameter, context).then((getdata) {}, onError: (error) {});
  }

  static Future<String> _downloadAndSaveImage(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }


  static Future<void> generateImageNotication(String title, String msg, String image, String type) async {
    var largeIconPath = await _downloadAndSaveImage(image, image.split('/').last);
    var bigPicturePath = await _downloadAndSaveImage(image, image.split('/').last);
    var bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('big text channel id', 'big text channel name',
        channelDescription: 'big text channel description',
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        styleInformation: bigPictureStyleInformation);
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(sound: 'notification.aiff');
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type);
  }

  static Future<void> generateSimpleNotication(String title, String msg, String type) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(sound: 'notification.aiff');
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type);
  }
}

selectNotificationPayload(String? payload, BuildContext context) async {
  if (payload != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }
}

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  return Future<void>.value();
}

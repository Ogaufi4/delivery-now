import 'dart:io';

import 'package:project/app/routes.dart';
import 'package:project/ui/screen/home/home_screen.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/ui/screen/ticket/chat_screen.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

backgroundMessage(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotificationUtility {
  late BuildContext context;
  NotificationUtility({required this.context});
  void initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/notification_icon');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );

    //Android 13 or higher
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!);

            break;
          case NotificationResponseType.selectedNotificationAction:
            print("notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");

            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );
    _requestPermissionsForIos();
  }

  selectNotificationPayload(String? payload) async {
    print("payload:$payload");
    if (payload != null) {
      List<String> pay = payload.split(",");

      if (pay[0] == "products") {
      } else if (pay[0] == "categories") {
        Navigator.of(context)
            .pushNamed(Routes.cuisineDetail, arguments: {'categoryId': pay[1], 'name': UiUtils.getTranslatedLabel(context, deliciousCuisineLabel)});
      } else if (pay[0] == "wallet") {
        Navigator.of(context).pushNamed(Routes.wallet);
      } else if (pay[0] == "place_order" || pay[0] == "order") {
        Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
          'id': pay[1],
          'riderId': "",
          'riderName': "",
          'riderRating': "",
          'riderImage': "",
          'riderMobile': "",
          'riderNoOfRating': "",
          'isSelfPickup': "",
          'from': 'orderDetail'
        });
      } else if (pay[0] == "ticket_message") {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChatScreen(
                    id: pay[1],
                    status: "",
                  )),
        );
      } else if (pay[0] == "ticket_status") {
        Navigator.of(context).pushNamed(Routes.ticket);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.home);
      }
    }
  }

  Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions();
    }
  }

  Future<void> onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {}

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("type1:${message.data['type'].toString()}");
      if (streamController != null && !streamController!.isClosed) {
        if (message.data['type'].toString() == 'place_order' || message.data['type'].toString() == 'order') {
          streamController!.sink.add("1");
        }
      }
      print("data:onMessage");
      print("data notification*********************************${message.data}");
      var data = message.data;
      print("data notification*********************************$data");
      var title = (message.notification != null) ? message.notification!.title : data['title'].toString();
      var body = (message.notification != null) ? message.notification!.body : data['body'].toString();
      var type = data['type'].toString();
      var image = (message.notification != null)
          ? (message.notification!.android?.imageUrl ?? message.notification!.apple?.imageUrl)
          : data['image'].toString();
      var id = data['type_id'] ?? '';

      if (image != 'null' && image != '') {
        generateImageNotification(title!, body!, image!, type, id);
      } else {
        generateSimpleNotification(title!, body!, type, id);
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
    await Firebase.initializeApp();
    print("type2:${remoteMessage.data['type'].toString()}");
    //perform any background task if needed here
    if (streamController != null && !streamController!.isClosed) {
      if (remoteMessage.data['type'].toString() == 'place_order' || remoteMessage.data['type'].toString() == 'order') {
        streamController!.sink.add("1");
      }
    }
    if (Platform.isAndroid) {
      if (remoteMessage.notification == null) {
        var data = remoteMessage.data;
        print("data notification*********************************$data--${remoteMessage.notification}");
        var title = data['title'].toString();
        var body = data['body'].toString();
        var type = data['type'].toString();
        var image = data['image'].toString();
        var id = data['type_id'] ?? '';

        if (image != 'null' && image != '') {
          generateImageNotification(title, body, image, type, id);
        } else {
          generateSimpleNotification(title, body, type, id);
        }
      }
    }
  }

// notification type is move to screen
  Future<void> _handleMessage(RemoteMessage message) async {
    print(
        "type2:${message.data['type'].toString()}--${message.data['type'].toString() == 'place_order' || message.data['type'].toString() == 'order'}");
    if (streamController != null && !streamController!.isClosed) {
      if (message.data['type'].toString() == 'place_order' || message.data['type'].toString() == 'order') {
        streamController!.sink.add("1");
      }
    }
    if (message.data['type'] == 'category') {
      Navigator.of(context).pushNamed(Routes.cuisine, arguments: false);
    }
    if (message.data['type'] == "products") {
    } else if (message.data['type'] == "categories") {
      Navigator.of(context).pushNamed(Routes.cuisineDetail,
          arguments: {'categoryId': message.data['type_id'], 'name': UiUtils.getTranslatedLabel(context, deliciousCuisineLabel)});
    } else if (message.data['type'] == "wallet") {
      Navigator.of(context).pushNamed(Routes.wallet);
    } else if (message.data['type'] == 'place_order' || message.data['type'] == 'order') {
      Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
        'id': message.data['type_id'],
        'riderId': "",
        'riderName': "",
        'riderRating': "",
        'riderImage': "",
        'riderMobile': "",
        'riderNoOfRating': "",
        'isSelfPickup': "",
        'from': 'orderDetail'
      });
    } else if (message.data['type'] == "ticket_message") {
      Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChatScreen(
                  id: message.data['type_id'],
                  status: "",
                )),
      );
    } else if (message.data['type'] == "ticket_status") {
      Navigator.of(context).pushNamed(Routes.ticket);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  static DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
    categoryIdentifier: "",
  );

  static Future<void> generateImageNotification(String title, String msg, String image, String type, String? id) async {
    var largeIconPath = await _downloadAndSaveFile(image, image.split('/').last);
    var bigPicturePath = await _downloadAndSaveFile(image, image.split('/').last);
    var bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.konnect.erestro', //channel id
      'eKonnect', //channel name
      channelDescription: 'eKonnect', //channel description

      largeIcon: FilePathAndroidBitmap(largeIconPath),

      styleInformation: bigPictureStyleInformation,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "$type,${id!}");
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // notification on foreground
  static Future<void> generateSimpleNotification(String title, String msg, String type, String? id) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'com.konnect.erestro', //channel id
      'eKonnect', //channel name
      channelDescription: 'eKonnect', //channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "$type,${id!}");
  }
}

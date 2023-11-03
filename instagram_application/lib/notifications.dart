import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notifications = FlutterLocalNotificationsPlugin();

//1. 앱로드시 실행할 기본설정
initNotification(context) async {
  //안드로이드용 아이콘파일 이름
  var androidSetting = AndroidInitializationSettings('app_icon1');

  //ios에서 앱 로드시 유저에게 권한요청하려면
  var iosSetting = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings =
      InitializationSettings(android: androidSetting, iOS: iosSetting);
  await notifications.initialize(initializationSettings,
      //알림 누를때 함수실행하고 싶으면
      onSelectNotification: (payload) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Text("새로운 페이지");
    }));
  });

  print("알림준비완료");
}

//2. 이 함수 원하는 곳에서 실행하면 알림 뜸
showNotification() async {
  var androidDetails = AndroidNotificationDetails(
    '준스타그램',
    '알림알림알림',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 244, 34, 34),
  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // 알림 id, 제목, 내용 맘대로 채우기
  notifications.show(1, '준스타그램알림이요~', '그냥알람이요~',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: '부가정보');
  print("알림함수~!");
}

showNotification2() async {
  tz.initializeTimeZones();

  var androidDetails = const AndroidNotificationDetails(
    '준수알림',
    '알림종류뭐게',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );
  var iosDetails = const IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  notifications.zonedSchedule(2, '카리나에요', '에스파멤버 기다려요', makeDate(8, 30, 0),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);

  print("알림함수~!반복");
}

makeDate(hour, min, sec) {
  var now = tz.TZDateTime.now(tz.local);
  var when =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min, sec);
  if (when.isBefore(now)) {
    return when.add(Duration(days: 1));
  } else {
    return when;
  }
}

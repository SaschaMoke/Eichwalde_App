import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  //Initialize

  Future<void> initNotification() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final String currentTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone));

    const initSettingsAndroid = 
      AndroidInitializationSettings('@drawable/wappen_eichwalde_notifi');

    const initSettingsIOS = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  //NotificationsDetailSetup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_notifications_ID', 
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  //Show Notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body, 

  }) async {
    return notificationsPlugin.show(
      id, 
      title, 
      body //= //<= hier irgendwie aktuelle daten
//'''${departures[0].line}  ${departures[0].destination}  ${departures[0].when.substring(11,16)}                    
//${departures[1].line}  ${departures[1].destination}  ${departures[1].when.substring(11,16)}
//${departures[2].line}  ${departures[2].destination}  ${departures[2].when.substring(11,16)}'''
      ,

      notificationDetails(),
    );
  }

  //Scheduled Notification
  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour, //(0-23)
    required int minute, //(0-59)
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local, 
      now.year,
      now.month,
      now.day,
      hour,
      minute
    );

    await notificationsPlugin.zonedSchedule(
      id, 
      title, 
      body = 'Hi', //<= hier irgendwie aktuelle daten
      scheduledDate, 
      notificationDetails(), 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      //Daily repeat (togglebar machen)
      matchDateTimeComponents: DateTimeComponents.time,
    );

    //notificationsPlugin.cancel(id)  <- toggle ding
    Future<void> cancelAllNotifications() async {
      await notificationsPlugin.cancelAll();
    }
  }
}
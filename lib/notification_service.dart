import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:eichwalde_app/Assets/wappen_Eichwalde.png';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  //Initialize

  Future<void> initNotification() async {
    if (_isInitialized) return;

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
      body, 
      notificationDetails(),
    );
  }
}
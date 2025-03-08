import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

List notificationdepartures = [];
class NotificationDeparture {
  final String destination;
  final String? when;
  final String plannedWhen;
  final String line;

  NotificationDeparture({
    required this.destination,
    this.when,
    this.plannedWhen = '',
    this.line = 'Unbekannt',
  });
  
  factory NotificationDeparture.fromJson(Map<String, dynamic> json) {
    return NotificationDeparture(
      destination: json['destination']['name'],
      when: json['when'] ?? 'Fahrt fällt aus',
      plannedWhen: json['plannedWhen'],
      line: json['line']['name'],
    );
  }
}
class NotificationVBBApiResponse {
  final List notidepartures;
  const NotificationVBBApiResponse({
    required this.notidepartures,
  });

  factory NotificationVBBApiResponse.fromJson(Map<String, dynamic> json) {
    return NotificationVBBApiResponse(
      notidepartures: List.from(json['departures'].map((x) => NotificationDeparture.fromJson(x)),),
    );
  }
}
Future<String> getAPIData() async {
  try {
    final response = await http.get(
      Uri.parse('https://v6.vbb.transport.rest/stops/900260004/departures?linesOfStops=false&remarks=false&duration=60'),
    );

      if (response.statusCode == 200) {
        final apiResponse = NotificationVBBApiResponse.fromJson(jsonDecode(response.body));
          notificationdepartures = apiResponse.notidepartures;
        notificationdepartures.sort((a, b) {
          final aTime = a.when ?? a.plannedWhen;
          final bTime = b.when ?? b.plannedWhen;
          return aTime.compareTo(bTime);
        });
      } else {
        throw Exception('Failed to load data');        //evtl anzeigen lassen 
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');             //evtl anzeigen lassen
    }
  return 
'''${notificationdepartures[0].line}  ${notificationdepartures[0].destination}  ${notificationdepartures[0].when.substring(11,16)}                    
${notificationdepartures[1].line}  ${notificationdepartures[1].destination}  ${notificationdepartures[1].when.substring(11,16)}
${notificationdepartures[2].line}  ${notificationdepartures[2].destination}  ${notificationdepartures[2].when.substring(11,16)}''';
}

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
 
 // @pragma('vm: entry-point')
 // void notificationTapBackground(NotificationResponse notificationResponse) {
 //   showNotification();
 // }
  
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

    await notificationsPlugin.initialize(
      initSettings,
      //onDidReceiveBackgroundNotificationResponse:notificationTapBackground,
    );
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
    //getAPIData();
    return notificationsPlugin.show(
      id, 
      title, 
      body = 'Hallo',
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
      body = 'Hi',//await getAPIData(),
      scheduledDate, 
      notificationDetails(), 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      //Daily repeat (togglebar machen)
      matchDateTimeComponents: DateTimeComponents.time,
      //payload: 'Hallo',
    );

    //notificationsPlugin.cancel(id)  <- toggle ding
    Future<void> cancelAllNotifications() async {
      await notificationsPlugin.cancelAll();
    }
  }

}


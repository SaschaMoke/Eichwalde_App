import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

List notidepartures = [];
class Departure {
  final String destination;
  final String? when;
  final String plannedWhen;
  final String line;

  Departure({
    required this.destination,
    this.when,
    this.plannedWhen = '',
    this.line = 'Unbekannt',
  });
  
  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      destination: json['destination']['name'],
      when: json['when'] ?? 'Fahrt fällt aus',
      plannedWhen: json['plannedWhen'],
      line: json['line']['name'],
    );
  }
}
class NotificationVBBApi {
  final List departures;
  const NotificationVBBApi({
    required this.departures,
  });
  factory NotificationVBBApi.fromJson(Map<String, dynamic> json) {
    return NotificationVBBApi(
      departures: List.from(json['departures'].map((x) => Departure.fromJson(x)),),
    );
  }
}

Future<void> getAPIData() async {
    try {
      final response = await http.get(
        Uri.parse('https://v6.vbb.transport.rest/stops/900260004/departures?linesOfStops=false&remarks=false&duration=60'),
      );

      if (response.statusCode == 200) {
        final apiResponse = NotificationVBBApi.fromJson(jsonDecode(response.body));
        notidepartures = apiResponse.departures;
        notidepartures.sort((a, b) {
          final aTime = a.when ?? a.plannedWhen;
          final bTime = b.when ?? b.plannedWhen;
          return aTime.compareTo(bTime);
        });
      } else {
        throw Exception('Failed to load data');        //evtl anzeigen lassen 
      }
    } catch (error) {
      print('Error fetching data: $error');             //evtl anzeigen lassen
    }
  }


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

    await notificationsPlugin.initialize(
      initSettings,
      /*onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == 'API_Call') {
          await getAPIData(); // Holt den Inhalt
          await NotificationService().showNotification(
            id: response.id ?? 0,
            title: 'Nächste Abfahrten in Eichwalde:', // dynamisch
            body: 
'''${notidepartures[0].line}  ${notidepartures[0].destination}  ${notidepartures[0].when.substring(11,16)}                    
${notidepartures[1].line}  ${notidepartures[1].destination}  ${notidepartures[1].when.substring(11,16)}
${notidepartures[2].line}  ${notidepartures[2].destination}  ${notidepartures[2].when.substring(11,16)}''',
          );
        }
      },*/
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
      body = //<= hier irgendwie aktuelle daten
'''${notidepartures[0].line}  ${notidepartures[0].destination}  ${notidepartures[0].when.substring(11,16)}                    
${notidepartures[1].line}  ${notidepartures[1].destination}  ${notidepartures[1].when.substring(11,16)}
${notidepartures[2].line}  ${notidepartures[2].destination}  ${notidepartures[2].when.substring(11,16)}''',

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
      body /*= 'Aktualisiere Daten...'*/,
      scheduledDate, 
      notificationDetails(), 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      //Daily repeat (togglebar machen)
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'API_Call',
    );

    //notificationsPlugin.cancel(id)  <- toggle ding
    Future<void> cancelAllNotifications() async {
      await notificationsPlugin.cancelAll();
    }
  }
}
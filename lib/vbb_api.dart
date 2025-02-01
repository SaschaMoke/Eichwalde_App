import 'package:intl/intl.dart';

class Departure {
  final String destination;
  final String when;
  final int delay;
  final String? platform;
  final String line;
  final String product;
  //final bool? cancelled;

  Departure({
    required this.destination,
    this.when = 'Fahrt fällt aus',
    this.delay = 0,
    this.platform,
    this.line = 'Unbekannt',
    this.product = 'Unbekannt',
    //this.cancelled,
  });
  
  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      destination: json['destination']['name'],
      when: json['when'] ?? 'Fahrt fällt aus',
      delay: json['delay'] ?? 0,
      platform: json['platform'],
      line: json['line']['name'],
      product: json['line']['product'],
      //cancelled: json['cancelled'],
    );
  }
  String get formattedHour {
    try {
      final dateTime = DateTime.parse(when).toLocal();
      return DateFormat('HH').format(dateTime); // Nur Stunden
    } catch (e) {
      return "0"; 
    }
  }
  String get formattedMin {
    try {
      final dateTime = DateTime.parse(when).toLocal();
      return DateFormat('mm').format(dateTime); // Nur Minuten
    } catch (e) {
      return "0"; 
    }
  }
}
class VBBApiResponse {
  final List departures;
  final DateTime lastUpdate;

  const VBBApiResponse({
    required this.departures,
    required this.lastUpdate,
  });

//numbers.sort((a, b) => a.length.compareTo(b.length));
  factory VBBApiResponse.fromJson(Map<String, dynamic> json) {
    return VBBApiResponse(
      departures: List.from(json['departures'].map((x) => Departure.fromJson(x)),),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['realtimeDataUpdatedAt']),
    );
  }
}
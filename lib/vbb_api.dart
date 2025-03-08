import 'package:intl/intl.dart';

enum Stations {
  eichwalde('S Eichwalde', 900260004),
  friedenstr('Eichwalde, Friedenstr.', 900260665),
  schmockwitz('Eichwalde, Schmöckwitzer Str.', 900260669);

  const Stations(this.stationName, this.stationID);
  final String stationName;
  final int stationID;
}

List<Departure> schrankeTrains = [];
int nextClose = 100;
int nextOpen = 100; 
//check ausfall - evtl. schon automatisch
bool checkSchranke(List departures, String schrankeOrt) {
  DateTime nowSchranke = DateTime.now();
  var currentHourSchranke = int.parse(DateFormat('HH').format(nowSchranke));
  var currentMinSchranke = int.parse(DateFormat('mm').format(nowSchranke));
  
  schrankeTrains = [];
  nextClose = 100;
  nextOpen = 0; 

  for (var dep in departures) {
    if (dep.product == 'suburban') {
      int mincountSchranke;
      var formattedHour = int.parse(dep.formattedHour);
      var formattedMin = int.parse(dep.formattedMin);
      if (formattedHour == currentHourSchranke) {
        mincountSchranke = (formattedMin-currentMinSchranke);
      } else {
        mincountSchranke = (formattedMin+(60-currentMinSchranke));
      }

      if (schrankeOrt == 'Lidl') {
        if (dep.platform == '4') {
          mincountSchranke = mincountSchranke - 1;
        } else if (dep.platform == '3') {
          mincountSchranke = mincountSchranke + 1;
        }
      } else {
         if (dep.platform == '3') {
          mincountSchranke = mincountSchranke - 1;
        } else if (dep.platform == '4') {
          mincountSchranke = mincountSchranke + 1;
        }
      }

      if (mincountSchranke < nextClose) {
        nextClose = mincountSchranke;
      }

      if (mincountSchranke < 2) {
        if (!schrankeTrains.contains(dep)) {
          schrankeTrains.add(dep);
        }

        if (mincountSchranke > nextOpen) {
          nextOpen = mincountSchranke;
        }
      }
    }
  }
    
  if (schrankeTrains.isEmpty) {
    return false;
  } else {
    return true;
  }
}

class Departure {
  final String destination;
  final String? when;
  final String plannedWhen;
  final int delay;
  final String? platform;
  final String line;
  final String product;
  final String tripID;

  Departure({
    required this.destination,
    this.when,
    this.plannedWhen = '',
    this.delay = 0,
    this.platform,
    this.line = 'Unbekannt',
    this.product = 'Unbekannt',
    this.tripID = 'Unbekannt',
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Departure &&
        other.when == when &&
        other.tripID == tripID; 
  }
  @override
  int get hashCode => Object.hash(when, tripID);

  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      destination: json['destination']['name'],
      when: json['when'] ?? 'Fahrt fällt aus',
      plannedWhen: json['plannedWhen'],
      delay: json['delay'] ?? 0,
      platform: json['platform'],
      line: json['line']['name'],
      product: json['line']['product'],
      tripID: json['tripId'],
    );
  }
  String get formattedHour {
    try {
      final dateTime = DateTime.parse(when ?? plannedWhen).toLocal();
      return DateFormat('HH').format(dateTime); // Nur Stunden
    } catch (e) {
      return "0"; 
    }
  }
  String get formattedMin {
    try {
      final dateTime = DateTime.parse(when ?? plannedWhen).toLocal();
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

  factory VBBApiResponse.fromJson(Map<String, dynamic> json) {
    return VBBApiResponse(
      departures: List.from(json['departures'].map((x) => Departure.fromJson(x)),),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['realtimeDataUpdatedAt'] * 1000, ),
    );
    }
  }
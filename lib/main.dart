//import 'package:cron/cron.dart';
import 'package:eichwalde_app/gewerbe.dart';
import 'package:eichwalde_app/notification_service.dart';
import 'package:eichwalde_app/vbb_api.dart';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //init notifications
  NotificationService().initNotification();
  initializeDateFormatting('de_DE', null);  // Deutsch aktivieren
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(            
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: MyHomePage(),                 
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();                        
 var favorites = <WordPair>[];

  void GetNext() {                                        
    current = WordPair.random();
    notifyListeners();
  }

   void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

  Widget page;
  switch (selectedIndex) {
    case 0:
      page = Homepage();
      break;
    case 1:
      page = Verkehrspage();
      break;
    case 2:
      page = GewerbePage();
      break;
    case 3:
      page = Terminepage();
      break;
    default:
      throw UnimplementedError('no widget for $selectedIndex');
  }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          
         // floatingActionButton: FloatingActionButton(
           // onPressed: () {
                //setState(() {
                  //page = Placeholder();
                //selectedIndex = 2;
            //  }); 
            //},
            //foregroundColor: customizations[index].$1,
            //backgroundColor: customizations[index].$2,
            //shape: customizations[index].$3,
            //child: const Icon(Icons.settings),
          //),

          bottomNavigationBar: NavigationBarTheme(
            data:  const NavigationBarThemeData(
            labelTextStyle: WidgetStatePropertyAll(TextStyle(
                  color: Colors.black,
               ),
              )
            ),
            child: NavigationBar(
              backgroundColor: Color.fromRGBO(150, 200, 150, 1),
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
            });
            },
            indicatorColor: Theme.of(context).colorScheme.primaryContainer,
            selectedIndex: selectedIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'Home', 
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.route),
                icon: Icon(Icons.route_outlined),
                label: 'Verkehr',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.store),
                icon: Icon(Icons.store_outlined),
                label: 'Gewerbe',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.calendar_month),
                icon: Icon(Icons.calendar_month_outlined),
                label: 'Termine',
              ),
            ],
            ),
          ),
          body:Container(
            child: page,
          ),
        );
      }
    );
  }
}

class Verkehrspage extends StatefulWidget {
  const Verkehrspage({super.key});

  @override
  State<Verkehrspage> createState() => _VerkehrspageState();
}
  //evtl kein ausklappen
  //list sortieren nach zeit (sollte funktionieren, muss noch geprüft werden)
  //fahrt fällt aus schöner machen! (-//-)
  //benachrichtigung (Wecker)
  //appicon
  //Stationswahl mit DropdownMenu
class _VerkehrspageState extends State<Verkehrspage> {
  List departures = [];
  String lastUpdate = '';
  Timer? timer;
  int? expandedIndex;
  int? selectedindex;

  int currentPickedHour = 0;
  int currentPickedMinute = 0;

  @override
  void initState() {
    super.initState();
    fetchAndUpdateData(); 
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) => fetchAndUpdateData());
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void removeScheduleOverlay() {
    scheduleAlarmOverlay.remove();
    scheduleAlarmOverlay.dispose();
  }

  Future<void> fetchAndUpdateData() async {
    try {
      final response = await http.get(
        Uri.parse('https://v6.vbb.transport.rest/stops/900260004/departures?linesOfStops=false&remarks=false&duration=60'),
      );

      if (response.statusCode == 200) {
        final apiResponse = VBBApiResponse.fromJson(jsonDecode(response.body));
        setState(() {
          departures = apiResponse.departures;
          lastUpdate = apiResponse.lastUpdate.toString();
        });
        departures.sort((a, b) {
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

  void expand(int index) {
    setState(() {
      expandedIndex = (expandedIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var currentHour = int.parse(DateFormat('HH').format(now));
    var currentMin = int.parse(DateFormat('mm').format(now));

    return Scaffold(
        body: Center(
          child: Column(  
            children: [
              const SizedBox(
                height: 250,
              ),
              Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 150, 200, 150),
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255)
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 370,
                      child: Text(
                        textAlign: TextAlign.left,                //auf jeden Fall schöner machen
                        style: TextStyle(
                          fontSize: 30, 
                        ),
                        'S Eichwalde'
                      ),
                    ),
                    SizedBox(
                      height: 330,
                      child: ListView.builder(
                        itemCount: departures.length,
                        itemBuilder: (context, index) {
                        final departure = departures[index];
                        final expanded = expandedIndex == index;
                        
                        Color timecolor = const Color.fromARGB(255, 0, 0, 0);
                        var delay = (departure.delay)/60;
                        if (delay > 0 && delay < 5)  {
                          timecolor = const Color.fromARGB(255, 255, 135, 0);
                        } else if (delay > 5) {
                          timecolor = const Color.fromARGB(255, 255, 0, 0);
                        }
                        else {
                          timecolor = const Color.fromARGB(255, 0, 0, 0);
                        }

                        int mincount;
                        String deptime;
                        var formattedHour = int.parse(departure.formattedHour);
                        var formattedMin = int.parse(departure.formattedMin);
                        if (formattedHour == currentHour) {
                          mincount = (formattedMin-currentMin);
                        } else {
                          mincount = (formattedMin+(60-currentMin));
                        }
                        if (mincount == 0) {
                          if (delay > 0) {
                            deptime = 'jetzt (+ ${delay.round()})';
                          } else {
                            deptime = 'jetzt';
                          }
                        } else {
                          if (delay > 0) {
                            deptime = 'in $mincount min (+ ${delay.round()})';
                          } else {
                            deptime = 'in $mincount min';
                          }
                        }

                        TextStyle deststyle;
                        if (departure.when == 'Fahrt fällt aus') {
                          deststyle = const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 255, 0, 0),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color.fromARGB(255, 255, 0, 0),
                          );
                          deptime = 'Fahrt fällt aus';
                          timecolor = const Color.fromARGB(255, 255, 0, 0);
                        } else {
                          deststyle = const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 0),
                            decoration: TextDecoration.none,
                          );
                        }

                        AssetImage lineImage = const AssetImage('Assets/Bus.png');
                        SizedBox linelogo;
                        if (departure.product == 'suburban') {
                          if (departure.line == 'S46') {
                            lineImage = const AssetImage('Assets/S46.png');
                          } else if (departure.line == 'S8') {
                            lineImage = const AssetImage('Assets/S8.png');
                          }
                          linelogo = SizedBox(
                            height: 40,
                            width: 40,
                            child: Image(image: lineImage)
                          );
                        } else {
                          linelogo = SizedBox(
                            height: 60,
                            width: 40,
                            child: 
                              Column(
                                children: [
                                  Image(
                                    image: lineImage,
                                    height: 30,
                                    width: 30,
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    departure.line,
                                  ),
                                ],
                              ),
                          );
                        }

                        double tileheight;
                        IconData arrow;
                        int linecount;
                        if (expanded) {
                          tileheight = 160;
                          arrow = Icons.keyboard_arrow_up_rounded;
                          linecount = 2;
                        } else {
                          tileheight = 80;
                          arrow = Icons.keyboard_arrow_down_rounded;
                          linecount = 1;
                        }
                        return Center(
                          child: Column(
                            children:[
                              SizedBox(
                                width: 380,
                                height: tileheight,
                                child: Card(
                                  child: ListTile(
                                    onTap: () => expand(index),
                                    leading: SizedBox(
                                      height: 60,
                                      width: 40,
                                      child: linelogo,
                                    ),
                                      title: Text(
                                        style: deststyle,
                                        maxLines: linecount,
                                      departure.destination
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                           style: TextStyle(
                                             fontSize: 15,
                                             color: timecolor,
                                           ),
                                           deptime
                                        ),
                                        SizedBox(width: 25),
                                        Text(
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(255, 0, 0, 0),
                                          ),
                                          'Gleis: ${departure.platform}'
                                        ),
                                      ],
                                    ), 
                                    trailing: Icon(
                                      size: 25,
                                      arrow
                                    ),
                                  ),
                                ),
                              ),  
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Text(   //last update text
                    'Zuletzt aktualisiert: $lastUpdate')
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    fetchAndUpdateData();

                    NotificationService().showNotification(
                      title: "Nächste Abfahrten in Eichwalde:",  //dynmaisch!
                      body: 
'''${departures[0].line}  ${departures[0].destination}  ${departures[0].when.substring(11,16)}                    
${departures[1].line}  ${departures[1].destination}  ${departures[1].when.substring(11,16)}
${departures[2].line}  ${departures[2].destination}  ${departures[2].when.substring(11,16)}''',
                    );
                  }, 
                  child: const Text('Send Notification')
                ),

            //scheduled Notification
            //id muss fortlaufend gespeichert werden (entspricht anzahl an timern)
            //zudem müssen die timer gespeichert bleiben
                ElevatedButton(
                  onPressed: () {
                    fetchAndUpdateData();

                    NotificationService().scheduleNotification(
                      title: "Nächste Abfahrten in Eichwalde:",  //dynmaisch!
                      body: 
'''${departures[0].line}  ${departures[0].destination}  ${departures[0].when.substring(11,16)}                    
${departures[1].line}  ${departures[1].destination}  ${departures[1].when.substring(11,16)}
${departures[2].line}  ${departures[2].destination}  ${departures[2].when.substring(11,16)}''',
                      hour: currentPickedHour,
                      minute: currentPickedMinute,
                    );
                  }, 
                  child: const Text('Schedule Notification')
                ),
              ],
            ),
            Container(
              width: 400,
              height: 110,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 150, 200, 150),
                border: Border.all(
                  color: const Color.fromARGB(255, 255, 255, 255)
                ),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  NumberPicker(
                    infiniteLoop: true,
                    minValue: 0, 
                    maxValue: 23, 
                    value: currentPickedHour, //aktuelle Zeit?
                    onChanged: (value) => setState(() => currentPickedHour = value)
                  ),
                  NumberPicker(
                    infiniteLoop: true,
                    minValue: 0, 
                    maxValue: 59, 
                    value: currentPickedMinute, //aktuelle Zeit?
                    onChanged: (value) => setState(() => currentPickedMinute = value)
                  ),
                  ElevatedButton(
                    onPressed: () => Overlay.of(context).insert(scheduleAlarmOverlay),
                    child: const Text('Overlay test'))
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}

OverlayEntry scheduleAlarmOverlay = OverlayEntry(
  builder: (BuildContext context) {
    DateTime now = DateTime.now();
    int pickedHour = int.parse(DateFormat('HH').format(now));
    int pickedMinute = int.parse(DateFormat('mm').format(now));
    return Container(
      color: Color.fromARGB(100, 75, 75, 75),
      child: Column(
        children: [
          SizedBox(
            height: 250,
          ),
          SizedBox(
            width: 400,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 150, 200, 150),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                children: [
                  SizedBox(height: 75),
                  SizedBox(
                    height: 150,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        NumberPicker(
                          itemWidth: 185,
                          infiniteLoop: true,
                          minValue: 0, 
                          maxValue: 23, 
                          value: pickedHour, //aktuelle Zeit?
                          onChanged: (value) => _VerkehrspageState().currentPickedHour = value
                        ),
                        SizedBox(width: 10),
                        NumberPicker(
                          itemWidth: 185,
                          infiniteLoop: true,
                          minValue: 0, 
                          maxValue: 59, 
                          value: pickedMinute, //aktuelle Zeit?
                          onChanged: (value) => _VerkehrspageState().currentPickedMinute = value
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                  SizedBox(
                    height: 50,
                    width: 400,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            scheduleAlarmOverlay.remove();
                          }, 
                          child: Text('Abbrechen')
                        ),
                        ElevatedButton(
                          onPressed: () {
                           

                            scheduleAlarmOverlay.remove();
                          } , 
                          child: Text('Bestätigen')
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
);

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  return Column(
    children: [
      const SizedBox(height: 50),
      Row(
        children: [
          SizedBox(
            width: 25,
          ),
          SizedBox(
            height: 75,
            width: 75,
            child: Image(
              image: AssetImage('Assets/wappen_Eichwalde.png')
            ),
          ),
          SizedBox(
            width: 5
          ),
          Text(
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
            'Eichwalde'
          ),
        ],
      ),                              //Design
    ],
  );
  }
}

class GewerbePage extends StatefulWidget {

  @override
  State<GewerbePage> createState() => _GewerbePageState();
}

class _GewerbePageState extends State<GewerbePage> {

OverlayEntry? overlayEntry;



void removeOverlay() {
  overlayEntry?.remove();
  overlayEntry = null;
}

void showOverlay(BuildContext context, Gewerbe gewerbe, Offset position) {
  removeOverlay(); 
  final screenSize = MediaQuery.of(context).size;
  final overlayWidth = MediaQuery.of(context).size.width * 0.7;
  final overlayHeight =  210.00; 
  double dx = position.dx;
  double dy = position.dy;

  if (dx + overlayWidth > screenSize.width) {
      dx = screenSize.width - overlayWidth - 10;
    }
  if (dy + overlayHeight > screenSize.height) {
      dy = screenSize.height - overlayHeight - 10;
    }

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      left: MediaQuery.of(context).size.width * 0.1,  
      top: MediaQuery.of(context).size.longestSide * 0.62, 
      width: MediaQuery.of(context).size.width * 0.8, 
      height: overlayHeight,
      child: Material(
        elevation: 4,
        color: Color.fromARGB(255, 150, 200, 150),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ListTile(
              title: Text(gewerbe.adresse, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(gewerbe.gewerbeart),
            ),
            Divider(), 
            Padding(
              padding: EdgeInsets.all(10),
              child: Text('Telefon: +' + gewerbe.tel.toString()),
            ),
            TextButton(
              onPressed: removeOverlay, 
              child: Text("Schließen"),
            ),
          ],
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry!);
}

  @override

 /*List<bool> expandableState = List.generate(gewerbes.length, (index) => false);

  Widget bloc(double width, int index) {
    bool isExpanded = expandableState[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          expandableState[index] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: const EdgeInsets.all(10.0),
        width: isExpanded ? width * 0.9 : width * 0.45,
        height: isExpanded ? 300 : 200,
        decoration: BoxDecoration(
          color: Colors.green[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              gewerbes[index].image,
              width: isExpanded ? 120 : 80,
              height: isExpanded ? 120 : 80,
            ),
            const SizedBox(height: 10),
            Text(
              gewerbes[index].name,
              style: TextStyle(
                fontSize: isExpanded ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Text(
                gewerbes[index].adresse,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        title: Text(
          'Gewerbe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        itemCount: gewerbes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0, // Passt die Größe an
        ),
        itemBuilder: (context, index) {
          return bloc(width, index);
        },
      ),
    );
  }
} */

 Widget build(BuildContext context) {
 // List<bool> expandableState = List.generate(gewerbes.length, (index) => false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(150, 200, 150, 1),
        title:Text(
          'Gewerbe',
          style: TextStyle(
            color: Color.fromRGBO(222, 236, 209, 1),
            fontSize:40,
            //fontWeight: FontWeight.w500,
            letterSpacing:4.0,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        itemCount: gewerbes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( 
          crossAxisCount: 2,
          mainAxisExtent: 250,
          ),
        itemBuilder: (context, index) {
          return GestureDetector(
            /*onTap: () { setState(() {
              expandableState[index] = true;
            });*/
          
            onTapDown: (details) {
              showOverlay(context, gewerbes[index], details.globalPosition);
            },
            child:Container(
                        padding: EdgeInsets.all(0.5),
                        child:Card(
                          color: Color.fromARGB(255, 150, 200, 150),
                          child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 150,
                              height: 120,
                              child: Image(
                                image: AssetImage(gewerbes[index].image)
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                            width: 160,
                              child:Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(232, 240, 225, 1)
                              ),
                              textAlign: TextAlign.center,
                              gewerbes[index].name,
                              ),
                            ),
                          ]
                        ),
                      ),
                    ), 
                  );       

            }
           ),
         );
      }
}



class Terminepage extends StatefulWidget {
  @override
  _TerminepageState createState() => _TerminepageState();
}

class _TerminepageState extends State<Terminepage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  String _selectedService = "Einwohnermeldeamt";
  List<String> _services = [
    "Einwohnermeldeamt",
    "Abholung Ausweis/Pass",
    "Standesamt",
    "Sachgebiet Bildung und Soziales"
  ];
  TextEditingController _timeController = TextEditingController();

  void _addEvent(String event) {
    setState(() {
      final normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      _events.putIfAbsent(normalizedDay, () => []).add(event);
    });
  }

  Future<void> _selectTime(BuildContext context) async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    helpText: 'Uhrzeit auswählen',
    cancelText: 'Abbrechen',
    confirmText: 'OK',
    hourLabelText: 'Stunde',
    minuteLabelText: 'Minute',
  );

  if (picked != null) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    final formattedTime = DateFormat.Hm("de_DE").format(selectedDateTime);
    
    if (mounted) {
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(150, 200, 150, 1),
        title: Text(
          'Termine',
          style: TextStyle(
            color: Color.fromRGBO(222, 236, 209, 1),
            fontSize: 40,
            letterSpacing: 4.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'de_DE',
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]![index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _timeController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Termin buchen"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField(
                      value: _selectedService,
                      items: _services.map((service) {
                        return DropdownMenuItem(
                          value: service,
                          child: Text(service),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value.toString();
                        });
                      },
                      decoration: InputDecoration(labelText: "Dienstleistung"),
                    ),
                    TextField(
                      controller: _timeController,
                      decoration: InputDecoration(hintText: "Uhrzeit auswählen"),
                      readOnly: true,
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_timeController.text.isNotEmpty) {
                        _addEvent("$_selectedService um ${_timeController.text}");
                      }
                      Navigator.pop(context);
                    },
                    child: Text("Hinzufügen"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
//import 'package:cron/cron.dart';
import 'package:eichwalde_app/Read%20data/getGewerbeName.dart';
import 'package:eichwalde_app/gewerbe.dart';
import 'cloudgewerbe.dart';
//import 'Gewerbecloud.dart';
import 'package:eichwalde_app/notification_service.dart';
import 'package:eichwalde_app/vbb_api.dart';
import 'package:eichwalde_app/settings.dart';

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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'package:flutter_localizations/flutter_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey:"AIzaSyAkZE6Au_U_2O_OXfQXunONitfyUKRLBNc",
      projectId: "eichwalde-app-3527e",
      storageBucket: "eichwalde-app-3527e.firebasestorage.app",
      messagingSenderId: "684116063569",
      appId: "1:684116063569:web:5987b4a433b4ea3f644f70",
    )
  ); 
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
    case 4:
      page = SettingsPage();
      break;
    default:
      throw UnimplementedError('no widget for $selectedIndex');
  }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
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
               NavigationDestination(
                selectedIcon: Icon(Icons.settings),
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
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
  //ausklappen bei gewerbe nutzen
  //S Eichwalde steht schon in Auswahl
  //list sortieren nach zeit (sollte funktionieren, ausfall muss noch geprüft werden)
  //benachrichtigung (Wecker)
  //appicon schöner machen
  //dynamisch größen gerätgröße   "MediaQuery.of(context).size.width*0.2,"
class _VerkehrspageState extends State<Verkehrspage> {
  List departures = [];
  String lastUpdate = '';
  Timer? timer;
  int? expandedIndex;
  int? selectedindex;
  Stations? selectedStation = Stations.eichwalde;
  bool schranke = false;     

  int currentPickedHour = 0;
  int currentPickedMinute = 0;

  @override
  void initState() {
    super.initState();
    fetchAndUpdateData(); 
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) => fetchAndUpdateData());
    //setState(() {
      selectedStation = Stations.eichwalde;
    //});
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
        Uri.parse('https://v6.vbb.transport.rest/stops/${selectedStation?.stationID}/departures?linesOfStops=false&remarks=false&duration=60'),
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

        schranke = checkSchranke(departures);
      } else {
        throw Exception('Failed to load data');        //evtl anzeigen lassen 
      }
    } catch (error) {
      print('Error fetching data: $error');             //evtl anzeigen lassen
    }
  }

  void expand(int index) {          //expanded logik
    setState(() {
      expandedIndex = (expandedIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var currentHour = int.parse(DateFormat('HH').format(now));
    var currentMin = int.parse(DateFormat('mm').format(now));

    Color schrankeFrame;    //animieren wenn ändert
    Color schrankeRed;      //animieren wenn ändert
    Color schrankeGelb;     //animieren wenn ändert     last state variable
    if (schranke) {
      schrankeFrame = Color.fromARGB(255, 255, 0, 0);
      schrankeRed = Color.fromARGB(255, 255, 0, 0);
      schrankeGelb = Color.fromARGB(255, 50, 50, 50);           
    } else {
      schrankeFrame = Color.fromARGB(255, 0, 200, 0);
      schrankeRed = Color.fromARGB(255, 50, 50, 50);
      schrankeGelb = Color.fromARGB(255, 50, 50, 50);      
    }
    return Scaffold(
        body: Center(
          child: SafeArea(
            child: Column(  
              children: [
                Row(
                  children: [
                    SizedBox(width: 25), // MediaQuery.of(context).size.width*0.2 -- geht net
                    const SizedBox(
                      height: 75,
                      width: 75,
                      child: Image(
                        image: AssetImage('Assets/wappen_Eichwalde.png'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                    'Verkehr',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(   //Schrankencontainer
                  height: 200,
                  width: 400, 
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: schrankeFrame,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: Color.fromARGB(255, 235, 235, 235),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          SizedBox(
                            width: 185,
                            height: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  'Schranke'
                                ),
                                const Text(
                                  style: TextStyle(
                                    height: 0.1,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  'Friedensstraße'
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text('Anzahl Züge: ${schrankeTrains.length}'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 120,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: 100,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            child: Container( 
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: schrankeRed,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: schrankeGelb,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
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
                      const SizedBox(                           //Überschrift
                        height: 10,
                      ),
                      SizedBox(
                        height: 30,
                        width: 380,
                        child: DropdownMenu<Stations>(
                          width: 380,
                          initialSelection: Stations.eichwalde,
                          controller: TextEditingController(),
                          requestFocusOnTap: true,
                          label: const Text('Ausgewählte Haltestelle'),
                          onSelected: (Stations? val) {
                            setState(() {
                              selectedStation = val;
                            });
                            fetchAndUpdateData();
                          },
                          hintText: selectedStation!.stationName,
                          //helperText: 'Hello',
                          //errorText: null,
                          enableFilter: true,
                          dropdownMenuEntries: Stations.values.map<DropdownMenuEntry<Stations>>(
                            (Stations station) {
                              return DropdownMenuEntry<Stations>(
                                value: station,
                                label: station.stationName,
                                style: MenuItemButton.styleFrom(
                                  foregroundColor: Color.fromARGB(255, 0, 0, 0),
                                ),
                              );
                            }).toList(),
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 255, 255))
                          ),
                          textStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Color.fromARGB(255, 240, 240, 230),  //Farbe
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(12))
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 305,
                        child: ListView.builder(
                          itemCount: departures.length,
                          itemBuilder: (context, index) {
                          final departure = departures[index];
                          final expanded = expandedIndex == index;        //expanded logik
                          
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
                              deptime = 'jetzt (+${delay.round()})';
                            } else {
                              deptime = 'jetzt';
                            }
                          } else {
                            if (delay > 0) {
                              deptime = 'in $mincount min (+${delay.round()})';
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

                          //expanded logik anfang
                          IconData arrow;
                          if (expanded) {
                            arrow = Icons.keyboard_arrow_up_rounded;
                          } else {
                            arrow = Icons.keyboard_arrow_down_rounded;
                          }
                          //expanded logik ende
                          double tileheight;
                          int linecount;
                          if (departure.destination.length > 27) {
                            linecount = 2;
                            tileheight = 100;
                          } else {
                            linecount = 1;
                            tileheight = 80;
                          }

                          return Center(
                            child: Column(
                              children:[
                                SizedBox(
                                  width: 380,
                                  height: tileheight,
                                  child: Card(
                                    child: ListTile(
                                      onTap: () => expand(index),             //expanded logik
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
              /*Row(
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
              ),*/
            ],
                    ),
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



class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          //const SizedBox(height: 30),
          Row(
            children: [
              const SizedBox(width: 25),
              const SizedBox(
                height: 75,
                width: 75,
                child: Image(
                  image: AssetImage('Assets/wappen_Eichwalde.png'),
                ),
              ),
              SizedBox(width: 5),
              Text(
                'Eichwalde',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminCheckPage()),
              );
            },
            child: Text('Admin'),
          ),
        ],
      ),
    );
  }
}

class AdminCheckPage extends StatefulWidget {
  const AdminCheckPage({super.key});

  @override
  State<AdminCheckPage> createState() => _AdminCheckPageState();
}

class _AdminCheckPageState extends State<AdminCheckPage> {
   String Eingabe = '';
  
  void updateEingabe(String text){
    setState(() {
      Eingabe = text;
      
    });
    {if (Eingabe == '1234'){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
              }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
         /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.2,
              ),
              SizedBox(
                child:*/TextField(
                onSubmitted: updateEingabe,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Passwort'
                ),
                ),
           //   ),
       //     ]
  //       )
        ] 
     ),
    );
      
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Map<DateTime, List<String>> _events = {};

  final TextEditingController nameController = TextEditingController();
  final TextEditingController gewerbeartController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final Cloudgewerbe cloudGewerbe = Cloudgewerbe();
    

  void _clearFields() {
    nameController.clear();
    gewerbeartController.clear();
    adresseController.clear();
    telController.clear();
    imageController.clear();
  }

   Future _addGewerbe() async {
    String name = nameController.text;
    String gewerbeart = gewerbeartController.text;
    String adresse = adresseController.text;
    int? tel = int.tryParse(telController.text);
    String image = imageController.text;

    if (name.isNotEmpty && gewerbeart.isNotEmpty && adresse.isNotEmpty && tel != null) {
      await cloudGewerbe.addGewerbe(name, gewerbeart, adresse, tel, image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gewerbe erfolgreich hinzugefügt!")),
      );
      _clearFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitte alle Felder ausfüllen!")),
      );
    }
  }

  @override
  

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      Map<String, dynamic> decodedEvents = jsonDecode(eventsString);
      setState(() {
        _events = decodedEvents.map(
          (key, value) => MapEntry(DateTime.parse(key), List<String>.from(value)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: _events.isEmpty
          ? Center(child: Text("Keine Termine gefunden"))
          : ListView(
              children:[
                /*ListView(children: _events.entries.map((entry) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      "${entry.key.day}.${entry.key.month}.${entry.key.year}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entry.value.map((event) => Text(event)).toList(),
                    ),
                  ),
                );
              }).toList(),
              ),*/
            Card(
              child: Column(
              children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: gewerbeartController, decoration: InputDecoration(labelText: "Gewerbeart")),
            TextField(controller: adresseController, decoration: InputDecoration(labelText: "Adresse")),
            TextField(controller: telController, decoration: InputDecoration(labelText: "Telefonnummer"), keyboardType: TextInputType.number),
            TextField(controller: imageController, decoration: InputDecoration(labelText: "Bild-URL")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addGewerbe, child: Text("Gewerbe hinzufügen")),
          ],
        ),
      ),
     ]),
        
    );

  }
}

class GewerbePage extends StatefulWidget {

  @override
  State<GewerbePage> createState() => _GewerbePageState();
}

class _GewerbePageState extends State<GewerbePage> {

final Cloudgewerbe cloudGewerbe = Cloudgewerbe();

OverlayEntry? overlayEntry;


OverlayEntry? _overlayEntry;

void closeOverlay() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}

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
      body: FutureBuilder(
        future: cloudGewerbe.getDocId(),
        builder: (context, snapshot){
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( 
          crossAxisCount: 2,
          mainAxisExtent: 250,
            ),
          itemCount: cloudGewerbe.docIDs.length,
          itemBuilder: (context,index) {
            return GestureDetector(
              child: Container(
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
                              /*child: Image(
                                image: AssetImage(gewerbes[index].image)
                              ),*/
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                            width: 160,
                              child: Getgewerbename(documentId: cloudGewerbe.docIDs[index]),
                              ),
                          ]
                        ),
                      ),
                    ), 
                  );
          }
          );
        })
      /* GridView.builder(
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
          
            onTapDown: (details) {if (_overlayEntry != null){
              removeOverlay();
              } else {
              showOverlay(context, gewerbes[index], details.globalPosition);
            }
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
           ),*/
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
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _addEvent(String event) {
    setState(() {
      final normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      _events.putIfAbsent(normalizedDay, () => []).add(event);
      _saveEvents();
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<String>> stringEvents = _events.map((key, value) => MapEntry(key.toIso8601String(), value));
    await prefs.setString('events', jsonEncode(stringEvents));
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('events');
    if (eventsString != null) {
      Map<String, dynamic> decodedEvents = jsonDecode(eventsString);
      setState(() {
        _events = decodedEvents.map((key, value) => MapEntry(DateTime.parse(key), List<String>.from(value)));
      });
    }
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
          _nameController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Termin buchen"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Name eingeben"),
                    ),
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
                      if (_timeController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                        _addEvent("${_nameController.text} - $_selectedService um ${_timeController.text}");
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
//import 'package:cron/cron.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eichwalde_app/Read%20data/getGewerbeName.dart';
import 'package:eichwalde_app/Read%20data/getGewerbeimage.dart';
import 'package:eichwalde_app/Read%20data/getGewerbeart.dart';
import 'package:eichwalde_app/Read%20data/getGewerbeAdresse.dart';
import 'package:eichwalde_app/Read%20data/getGewerbeTel.dart';
import 'cloudgewerbe.dart';
//import 'Gewerbecloud.dart';
import 'package:eichwalde_app/notification_service.dart';
import 'package:eichwalde_app/vbb_api.dart';
import 'package:eichwalde_app/settings.dart';
//import 'package:eichwalde_app/gewerbe_layout_neu.dart';
import 'Newscloud.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'cloudtermine.dart';
//import 'package:numberpicker/numberpicker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: "AIzaSyAkZE6Au_U_2O_OXfQXunONitfyUKRLBNc",
      projectId: "eichwalde-app-3527e",
      storageBucket: "eichwalde-app-3527e.firebasestorage.app",
      messagingSenderId: "684116063569",
      appId: "1:684116063569:web:5987b4a433b4ea3f644f70",
    ));
  } else {
    await Firebase.initializeApp(
        /*   options: FirebaseOptions(
      apiKey: "AIzaSyAkZE6Au_U_2O_OXfQXunONitfyUKRLBNc",
      projectId: "eichwalde-app-3527e",
      storageBucket: "eichwalde-app-3527e.firebasestorage.app",
      messagingSenderId: "684116063569",
      appId: "1:684116063569:web:5987b4a433b4ea3f644f70",
    )*/
        );
  }
  //init notifications
  NotificationService().initNotification();
  initializeDateFormatting('de_DE', null); // Deutsch aktivieren
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
        //page = GewerbeLayoutNeu();
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

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        bottomNavigationBar: NavigationBarTheme(
          data: const NavigationBarThemeData(
              labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: Colors.black,
            ),
          )),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
        body: Container(
          child: page,
        ),
      );
    });
  }
}

class Verkehrspage extends StatefulWidget {
  const Verkehrspage({super.key});

  @override
  State<Verkehrspage> createState() => _VerkehrspageState();
}

//S Eichwalde steht schon in Auswahl
//schranke muss sich immer auf s eichwalde beziehen
//appicon schöner machen
//layout
class _VerkehrspageState extends State<Verkehrspage> {
  List departures = [];
  String lastUpdate = '';
  Timer? timer;
  //int? expandedIndex;
  int? selectedindex;
  Stations? selectedStation = Stations.eichwalde;
  bool schranke = false;
  String schrankeWahl = 'Lidl';
  final updateFormatTime = DateFormat('HH:mm:ss');
  final updateFormatDate = DateFormat('dd.MM.yyyy');

  int currentPickedHour = 0;
  int currentPickedMinute = 0;

  @override
  void initState() {
    super.initState();
    fetchAndUpdateData();
    timer = Timer.periodic(
    const Duration(seconds: 30), (Timer t) => fetchAndUpdateData());
    selectedStation = Stations.eichwalde;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /*void removeScheduleOverlay() {
    scheduleAlarmOverlay.remove();
    scheduleAlarmOverlay.dispose();
  }*/

  Future<void> fetchAndUpdateData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://v6.vbb.transport.rest/stops/${selectedStation?.stationID}/departures?linesOfStops=false&remarks=false&duration=60'),
        //Uri.parse('https://v6.vbb.transport.rest/stops/900192001/departures?linesOfStops=false&remarks=false&duration=60'),       Schöneweide als Test
      );

      if (response.statusCode == 200) {
        final apiResponse = VBBApiResponse.fromJson(jsonDecode(response.body));
        setState(() {
          departures = apiResponse.departures;
          lastUpdate = '${updateFormatDate.format(apiResponse.lastUpdate)}, ${updateFormatTime.format(apiResponse.lastUpdate)}';
        });
        departures.sort((a, b) {
          String aTime = a.when; 
          if (a.when == 'Fahrt fällt aus') {
            aTime = a.plannedWhen;
          }
          String bTime = b.when; 
          if (b.when == 'Fahrt fällt aus') {
            bTime = b.plannedWhen;
          }
          return aTime.compareTo(bTime);
        });

        schranke = checkSchranke(departures, schrankeWahl);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Error fetching data: $error');
    }
  }

  /*void expand(int index) {
    //expanded logik
    setState(() {
      expandedIndex = (expandedIndex == index) ? null : index;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var currentHour = int.parse(DateFormat('HH').format(now));
    var currentMin = int.parse(DateFormat('mm').format(now));

    Color schrankeFrame; 
    Color schrankeRed; 
    Color schrankeGelb; //animieren wenn ändert     last state variable
    if (schranke) {
      schrankeFrame = Color.fromARGB(255, 255, 0, 0);
      schrankeRed = Color.fromARGB(255, 255, 0, 0);
      schrankeGelb = Color.fromARGB(255, 50, 50, 50);
    } else {
      schrankeFrame = Color.fromARGB(255, 0, 200, 0);
      schrankeRed = Color.fromARGB(255, 50, 50, 50);
      schrankeGelb = Color.fromARGB(255, 50, 50, 50);
    }

    String schrankeName;
    if (schrankeWahl == 'Lidl') {
      schrankeName = 'Friedensstraße';
    } else {
      schrankeName = 'Waldstraße';
    }

    String schrankeTimeTillAction;
    if (schranke) {
      schrankeTimeTillAction = 'Nächste Öffnung vorraussichtlich in: $nextOpen min';
    } else {
      schrankeTimeTillAction = 'Nächste Schließung vorraussichtlich in: $nextClose min';
    }

    return Scaffold(
      body: Center(
        child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  //width: 25
                  width: MediaQuery.of(context).size.width*0.06,                
                ),
                SizedBox(
                  //height: 75,
                  //width: 75,
                  height: MediaQuery.of(context).size.height*0.08,   
                  width: MediaQuery.of(context).size.width*0.175,   
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
            SizedBox(
              //height: 20,
              height: MediaQuery.of(context).size.height*0.022,
            ),
            AnimatedContainer(
              //Schrankencontainer
              duration: Duration(milliseconds: 500),
              height: MediaQuery.of(context).size.height*0.215,
              width: MediaQuery.of(context).size.width*0.95,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 5,
                  color: schrankeFrame,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 235, 235, 235),
              ),
              child: departures.isNotEmpty ? Column(
                children: [
                  SizedBox(
                    //height: 10,
                    height: MediaQuery.of(context).size.height*0.011,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        //width: 15,
                        width: MediaQuery.of(context).size.width*0.035,
                      ),
                      SizedBox(
                        //width: 185,
                        //height: 100,
                        width: MediaQuery.of(context).size.width*0.43,
                        height: MediaQuery.of(context).size.height*0.107,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w500,
                                ),
                                'Schranke'),
                            Text(
                                style: TextStyle(
                                  height: 0.1,
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                                schrankeName
                                ),
                            SizedBox(
                              //height: 15,
                              height: MediaQuery.of(context).size.height*0.016,
                            ),
                            Text(schrankeTimeTillAction),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info_outline_rounded),
                            onPressed: () {},
                            tooltip: 'Der Status der Schranke ist eine Berechnung aus Abfahrtszeiten. Keine Garantie für Richtigkeit. Aktuell werden nur die Daten der S-Bahn Berlin verarbeitet!',
                          ),
                          SizedBox(
                            //width: 100,
                            //height: 40,
                            height: MediaQuery.of(context).size.height*0.043,
                            width: MediaQuery.of(context).size.width*0.23,
                            child: SegmentedButton(
                              segments: [
                                ButtonSegment(
                                  value: 'Lidl',
                                  label:
                                      Text(style: TextStyle(fontSize: 12), 'Lidl'),
                                ),
                                ButtonSegment(
                                  value: 'Wald',
                                  label:
                                      Text(style: TextStyle(fontSize: 12), 'Wald'),
                                ),
                              ],
                              selected: {schrankeWahl},
                              onSelectionChanged: (Set newSelection) {
                                setState(() {
                                  schrankeWahl = newSelection.first;
                                  schranke = checkSchranke(departures, schrankeWahl); //muss noch überprüft werden
                                });
                              },
                              showSelectedIcon: false,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        //width: 20,
                        width: MediaQuery.of(context).size.width*0.045,
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 100,
                        width: 60,
                        //height: MediaQuery.of(context).size.height*0.107,
                        //width: MediaQuery.of(context).size.width*0.14,
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
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                height: 26,
                                width: 26,
                                //height: MediaQuery.of(context).size.height*0.028,
                                //width: MediaQuery.of(context).size.width*0.06,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: schrankeRed,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                //height: MediaQuery.of(context).size.height*0.005,
                              ),
                              Container(
                                height: 26,
                                width: 26,
                                //height: MediaQuery.of(context).size.height*0.028,
                                //width: MediaQuery.of(context).size.width*0.06,
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
                  SizedBox(
                    //height: 5,
                    height: MediaQuery.of(context).size.height*0.005,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    height: 2,
                    color: Color.fromARGB(255, 50, 50, 50),
                  ),
                  SizedBox(
                    //height: 5,
                    height: MediaQuery.of(context).size.height*0.005,
                  ),
                  SizedBox(
                    //height: 68,
                    height: MediaQuery.of(context).size.height*0.07,
                    child: schrankeTrains.isNotEmpty
                        ? ListView.builder(
                            itemCount: schrankeTrains.length,
                            itemBuilder: (context, index) {
                              final train = schrankeTrains[index];
                              return Text(
                                  '${train.line}  ${train.destination}');
                            })
                        : Text('Keine Züge'),
                  ),
                ],
              ):Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                    'Es konnten keine Daten empfangen werden.'
                  ),
                )
            ),
            SizedBox(
              height: 20,
              //height: MediaQuery.of(context).size.height*0.021,
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.95,
              height: MediaQuery.of(context).size.height*0.43,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 150, 200, 150),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  SizedBox(
                    //Überschrift
                    height: 10,
                    //height: MediaQuery.of(context).size.height*0.011,
                  ),
                  SizedBox(
                    height: 30,
                    //height: MediaQuery.of(context).size.height*0.032,
                    width: MediaQuery.of(context).size.width*0.885,
                    child: DropdownMenu<Stations>(
                      width: MediaQuery.of(context).size.width*0.885,
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
                      dropdownMenuEntries: Stations.values
                          .map<DropdownMenuEntry<Stations>>((Stations station) {
                        return DropdownMenuEntry<Stations>(
                          value: station,
                          label: station.stationName,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: Color.fromARGB(255, 0, 0, 0),
                          ),
                        );
                      }).toList(),
                      menuStyle: MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              Color.fromARGB(255, 255, 255, 255))),
                      textStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Color.fromARGB(255, 240, 240, 230), //Farbe
                        border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    //height: MediaQuery.of(context).size.height*0.032,
                  ),
                  SizedBox(
                    //height: 305,
                    height: MediaQuery.of(context).size.height*0.327,
                    child: departures.isNotEmpty ? ListView.builder(
                      itemCount: departures.length,
                      itemBuilder: (context, index) {
                        final departure = departures[index];
                        //final expanded = expandedIndex == index;        //expanded logik

                        Color timecolor = const Color.fromARGB(255, 0, 0, 0);
                        var delay = (departure.delay) / 60;
                        if (delay > 0 && delay < 5) {
                          timecolor = const Color.fromARGB(255, 255, 135, 0);
                        } else if (delay > 5) {
                          timecolor = const Color.fromARGB(255, 255, 0, 0);
                        } else {
                          timecolor = const Color.fromARGB(255, 0, 0, 0);
                        }

                        int mincount;
                        String deptime;
                        var formattedHour = int.parse(departure.formattedHour);
                        var formattedMin = int.parse(departure.formattedMin);
                        if (formattedHour == currentHour) {
                          mincount = (formattedMin - currentMin);
                        } else {
                          mincount = (formattedMin + (60 - currentMin));
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

                        AssetImage lineImage =
                            const AssetImage('Assets/Bus.png');
                        SizedBox linelogo;
                        if (departure.product == 'suburban') {
                          if (departure.line == 'S46') {
                            lineImage = const AssetImage('Assets/S46.png');
                          } else if (departure.line == 'S8') {
                            lineImage = const AssetImage('Assets/S8.png');
                          }
                          linelogo = SizedBox(
                              //height: MediaQuery.of(context).size.height*0.1,
                              height: 40,
                              //width: 40,
                              width: MediaQuery.of(context).size.width*0.094,
                              child: Image(image: lineImage));
                        } else {
                          linelogo = SizedBox(
                            height: 60,
                            //width: 40,
                            width: MediaQuery.of(context).size.width*0.094,
                            child: Column(
                              children: [
                                Image(
                                  image: lineImage,
                                  height: 30,
                                  //width: 30,
                                  width: MediaQuery.of(context).size.width*0.07,
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
                        //IconData arrow;
                        //if (expanded) {
                        //  arrow = Icons.keyboard_arrow_up_rounded;
                        //} else {
                        //  arrow = Icons.keyboard_arrow_down_rounded;
                        //}
                        //expanded logik ende
                        double tileheight;
                        int linecount;
                        if (departure.destination.length > 22) {
                          linecount = 2;
                          tileheight = 100;
                          //tileheight = MediaQuery.of(context).size.height*0.107;
                        } else {
                          linecount = 1;
                          tileheight = 80;
                          //tileheight = MediaQuery.of(context).size.height*0.086;
                        }

                        return Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width*0.885,
                            height: tileheight,
                            child: Card(
                              child: ListTile(
                                //onTap: () => expand(index), //expanded logik
                                leading: linelogo, 
                                title: Text(
                                    style: deststyle,
                                    maxLines: linecount,
                                    departure.destination),
                                subtitle: Text(
                                  style: TextStyle(
                                    fontSize: 15,
                                      color: timecolor,
                                    ),
                                  deptime
                                ),                                  
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        'Gleis:'),
                                    Text(
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        '${departure.platform}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ): Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                        ),
                        'Es konnten keine Daten empfangen werden.'
                      ),
                    )
                  ),
                  Text(//last update text
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
      )),
    );
  }
}

/*OverlayEntry scheduleAlarmOverlay = OverlayEntry(
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
                  borderRadius: BorderRadius.circular(20)),
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
                            onChanged: (value) =>
                                _VerkehrspageState().currentPickedHour = value),
                        SizedBox(width: 10),
                        NumberPicker(
                            itemWidth: 185,
                            infiniteLoop: true,
                            minValue: 0,
                            maxValue: 59,
                            value: pickedMinute, //aktuelle Zeit?
                            onChanged: (value) => _VerkehrspageState()
                                .currentPickedMinute = value),
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
                            child: Text('Abbrechen')),
                        ElevatedButton(
                            onPressed: () {
                              scheduleAlarmOverlay.remove();
                            },
                            child: Text('Bestätigen')),
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
);*/

class Homepage extends StatefulWidget {
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  final Cloudnews cloudNews = Cloudnews();
  final CollectionReference newsCollection = FirebaseFirestore.instance.collection('News');

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
          SizedBox(
            height:500,
            width: MediaQuery.of(context).size.width*0.95,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 150, 200, 150),
                border: Border.all(),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(10),
              child: Column(children: [
                  Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                "📰 Aktuelle News", // 🔹 HINZUGEFÜGT: Überschrift für den News-Bereich
                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: newsCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                  }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Keine News gefunden"));
                  }

            return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: data['foto'] != null && data['foto'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(data['foto'], width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : Icon(Icons.image, size: 50),
                  title: Text(
                    data['titel'] ?? "Ohne Titel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Tippe, um mehr zu lesen"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(data['inhalt'] ?? "Kein Inhalt verfügbar"),
                    ),
                  ],
                ),
              );
          }).toList(),
            );
            },
          ),
                ),
           ],
        ),
            ),
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

  void updateEingabe(String text) {
    setState(() {
      Eingabe = text;
    });
    {
      if (Eingabe == '1234') {
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
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.2,
              ),
              SizedBox(
                child:*/
        TextField(
          onSubmitted: updateEingabe,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'Passwort'),
        ),
        //   ),
        //     ]
        //       )
      ]),
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

  @override
  void initState() {
    super.initState();
  }

   final CloudTermine cloudTermine = CloudTermine();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body:Column(children: [
         StreamBuilder<QuerySnapshot>(
        stream: cloudTermine.getTermineForDate(DateTime.now()), // Termine für das heutige Datum laden
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Ladeindikator, wenn die Daten noch abgerufen werden
          }

          if (snapshot.hasError) {
           return Center(child: Text("Fehler beim Laden der Termine: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Keine Termine gefunden"));
          }

          // Hier holen wir uns die Termine aus den Firestore-Daten
          var termine = snapshot.data!.docs;

          return SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: termine.length,
              itemBuilder: (context, index) {
                var termin = termine[index];
                DateTime date = DateTime.parse(termin['date']);
                String name = termin['name'];
                String service = termin['service'];
                String time = termin['time'];
            
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      "${date.day}.${date.month}.${date.year}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: $name"),
                        Text("Service: $service"),
                        Text("Time: $time"),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GewerbeHinzufuegenPage()),
              );
            },
            child: Text('Gewerbe hinzufügen')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GewerbeLoeschenPage()),
              );
            },
            child: Text('Gewerbe löschen')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminNewsHinzufuegenPage()),
              );
            },
            child: Text('News hinzufügen')),
      ]
      ),
      );
  }
}

class AdminNewsHinzufuegenPage extends StatefulWidget {
  const AdminNewsHinzufuegenPage({super.key});

  @override
  State<AdminNewsHinzufuegenPage> createState() => _AdminNewsHinzufuegenPageState();
}

class _AdminNewsHinzufuegenPageState extends State<AdminNewsHinzufuegenPage> {
  final TextEditingController titelController = TextEditingController();
  final TextEditingController inhaltController = TextEditingController();
  final TextEditingController fotoUrlController = TextEditingController();

  final Cloudnews cloudNews = Cloudnews(); // Instanz von CloudNews

  Future<void> _addNews() async {
    String titel = titelController.text;
    String inhalt = inhaltController.text;
    String fotoUrl = fotoUrlController.text;

    if (titel.isNotEmpty && inhalt.isNotEmpty && fotoUrl.isNotEmpty) {
      await cloudNews.addNews(titel, inhalt, fotoUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("News erfolgreich hinzugefügt!")),
      );
      _clearFields();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitte alle Felder ausfüllen!")),
      );
    }
  }

  void _clearFields() {
    titelController.clear();
    inhaltController.clear();
    fotoUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News hinzufügen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             TextField(
              controller: titelController,
              decoration: InputDecoration(labelText: "Titel"),
            ),
            SizedBox(height: 10), 
            TextField(
              controller: inhaltController,
              decoration: InputDecoration(labelText: "Inhalt"),
              maxLines: 6,
            ),
            SizedBox(height: 10),
            TextField(
              controller: fotoUrlController,
              decoration: InputDecoration(labelText: "Bild-URL"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addNews, child: Text("News hinzufügen")),
          ],
        ),
      ),
    );
  }
}

class GewerbeHinzufuegenPage extends StatefulWidget {
  const GewerbeHinzufuegenPage({super.key});

  @override
  State<GewerbeHinzufuegenPage> createState() => _GewerbeHinzufuegenPageState();
}

class _GewerbeHinzufuegenPageState extends State<GewerbeHinzufuegenPage> {
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

    if (name.isNotEmpty &&
        gewerbeart.isNotEmpty &&
        adresse.isNotEmpty &&
        tel != null) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name")),
            TextField(
                controller: gewerbeartController,
                decoration: InputDecoration(labelText: "Gewerbeart")),
            TextField(
                controller: adresseController,
                decoration: InputDecoration(labelText: "Adresse")),
            TextField(
                controller: telController,
                decoration: InputDecoration(labelText: "Telefonnummer"),
                keyboardType: TextInputType.number),
            TextField(
                controller: imageController,
                decoration: InputDecoration(labelText: "Bild-URL")),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _addGewerbe, child: Text("Gewerbe hinzufügen")),
          ],
        ),
      ),
    );
  }
}

class GewerbeLoeschenPage extends StatefulWidget {
  const GewerbeLoeschenPage({super.key});

  @override
  State<GewerbeLoeschenPage> createState() => _GewerbeLoeschenPageState();
}

class _GewerbeLoeschenPageState extends State<GewerbeLoeschenPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gewerbeartController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final Cloudgewerbe cloudGewerbe = Cloudgewerbe();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Gewerbe').snapshots(),
        builder: (context, snapshot) {
          //print("StreamBuilder aktualisiert!");
          //print("ConnectionState: ${snapshot.connectionState}");

          if (snapshot.connectionState == ConnectionState.waiting) {
            //print("Warte auf Daten...");
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            //print("Fehler: ${snapshot.error}");
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            //print("Keine Daten vorhanden!");
            return Center(child: Text('Keine Gewerbe gefunden'));
          }

          var docs = snapshot.data!.docs;
          //print("Daten empfangen: ${docs.length} Gewerbe");

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              //print("Dokument ${index + 1}: ${docs[index].id}");

              return ListTile(
                title: Text(docs[index]["name"] ?? "Kein Name"),
                leading: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirmDelete = await _showDeleteDialog(context);
                    if (confirmDelete) {
                      await FirebaseFirestore.instance
                          .collection('Gewerbe')
                          .doc(docs[index].id)
                          .delete();
                      //print("Dokument gelöscht: ${docs[index].id}");
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dialog zur Bestätigung des Löschens
  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Löschen bestätigen"),
            content: Text("Möchtest du dieses Gewerbe wirklich löschen?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Abbrechen"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Löschen", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
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

  void showOverlay(
      BuildContext context, String documentId, Offset position, int index) {
    removeOverlay();
    final screenSize = MediaQuery.of(context).size;
    final overlayWidth = MediaQuery.of(context).size.width * 0.7;
    final overlayHeight = 210.00;
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
                title:
                    GetgewerbeAdresse(documentId: cloudGewerbe.docIDs[index]),
                subtitle: Getgewerbeart(documentId: cloudGewerbe.docIDs[index]),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.all(10),
                child: GetgewerbeTel(documentId: cloudGewerbe.docIDs[index]),
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
          title: Text(
            'Gewerbe',
            style: TextStyle(
              color: Color.fromRGBO(222, 236, 209, 1),
              fontSize: 40,
              //fontWeight: FontWeight.w500,
              letterSpacing: 4.0,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: cloudGewerbe.getDocId(),
            builder: (context, snapshot) {
              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 250,
                  ),
                  itemCount: cloudGewerbe.docIDs.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTapDown: (details) {
                        if (_overlayEntry != null) {
                          removeOverlay();
                        } else {
                          showOverlay(context, cloudGewerbe.docIDs[index],
                              details.globalPosition, index);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(0.5),
                        child: Card(
                          color: Color.fromARGB(255, 150, 200, 150),
                          child: Column(children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 150,
                              height: 120,
                              child: Getgewerbeimage(
                                  documentId: cloudGewerbe.docIDs[index]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 160,
                              child: Getgewerbename(
                                  documentId: cloudGewerbe.docIDs[index]),
                            ),
                          ]),
                        ),
                      ),
                    );
                  });
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
  final CloudTermine cloudTermine = CloudTermine(); // Instanz von CloudTermine

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedService = "Einwohnermeldeamt";
  List<String> _services = [
    "Einwohnermeldeamt",
    "Abholung Ausweis/Pass",
    "Standesamt",
    "Sachgebiet Bildung und Soziales"
  ];
  TextEditingController _timeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

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
      final selectedDateTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final formattedTime = DateFormat.Hm("de_DE").format(selectedDateTime);

      if (mounted) {
        setState(() {
          _timeController.text = formattedTime;
        });
      }
    }
  }

  void _deleteTermin(String docId) async {
    try {
      await cloudTermine.deleteGewerbe(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Termin gelöscht")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Löschen des Termins")),
      );
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
             headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            daysOfWeekHeight: 20,
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
            child: FutureBuilder<QuerySnapshot>(
              future: cloudTermine.getTermineForDate(_selectedDay).first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("Keine Termine an diesem Tag"));
                }
                
                return Column(children: [
                   Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Bereits belegte Termine",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                   key: ValueKey(_selectedDay),
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 4,
                      child: ListTile(
                        title: Text('${data['service']}'),
                        subtitle: Text("Uhrzeit: ${data['time']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTermin(doc.id),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                )
                ]
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
                    onPressed: () async {
                      if (_timeController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                        bool success = await cloudTermine.addTermin(
                          _nameController.text,
                          _selectedService,
                          _timeController.text,
                          _selectedDay,
                        );

                        if (!success) {
                         
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Mindestens 5 Minuten Abstand zum nächsten Termin erforderlich!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          setState(() {}); 
                        }
                      }
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

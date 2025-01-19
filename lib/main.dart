import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
      return "N/A"; 
    }
  }
  String get formattedMin {
    try {
      final dateTime = DateTime.parse(when).toLocal();
      return DateFormat('mm').format(dateTime); // Nur Minuten
    } catch (e) {
      return "N/A"; 
    }
  }
}
class VBBApiResponse {
  final List departures;
  final int lastUpdate;

  const VBBApiResponse({
    required this.departures,
    required this.lastUpdate,
  });

  factory VBBApiResponse.fromJson(Map<String, dynamic> json) {
    return VBBApiResponse(
      departures: List.from(json['departures'].map((x) => Departure.fromJson(x)),),
      lastUpdate: json['realtimeDataUpdatedAt'],
    );
  }
}

void main() {
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
      page = BelaPage();
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
                selectedIcon: Icon(Icons.route),
                icon: Icon(Icons.route_outlined),
                label: 'Bela',
              ),
            ],
            ),
          ),
        body:Container(
                  //color: Theme.of(context).colorScheme.primaryContainer,
                
                  /* decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.5, 0.8),
                      end: Alignment(0.5, 1),
                      colors: <Color>[
                      Color.fromARGB(255, 230, 255, 230),
                      Color.fromARGB(255, 150, 200, 150),
                      ],
                    ),
                  ), */
                  child: page,
          ),
        );
      }
    );
  }
}

class Verkehrspage extends StatefulWidget {
  @override
  State<Verkehrspage> createState() => _VerkehrspageState();
}

class _VerkehrspageState extends State<Verkehrspage> {
    List departures = [];
    Timer? timer;

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

  Future<void> fetchAndUpdateData() async {
    try {
      final response = await http.get(
        Uri.parse('https://v6.vbb.transport.rest/stops/900260004/departures?linesOfStops=false&remarks=false&duration=60'),
      );

      if (response.statusCode == 200) {
        final apiResponse = VBBApiResponse.fromJson(jsonDecode(response.body));
        setState(() {
          departures = apiResponse.departures;
        });
      } else {
        throw Exception('Failed to load data');        //evtl anzeigen lassen 
      }
    } catch (error) {
      print('Error fetching data: $error');             //evtl anzeigen lassen
    }
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
                        
                        Color timecolor = const Color.fromARGB(255, 0, 0, 0);
                        var delay = (departure.delay)/60;
                        if (delay > 0 && delay < 5)  {
                          timecolor = const Color.fromARGB(255, 255, 175, 0);
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
                          );
                        } else {
                            deststyle = const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 0, 0, 0),
                            decoration: TextDecoration.none,
                          );
                        }

                        AssetImage lineImage = const AssetImage('Assets/Bus.png');
                        if (departure.product == 'suburban') {
                          if (departure.line == 'S46') {
                            lineImage = const AssetImage('Assets/S46.png');
                          } else if (departure.line == 'S8') {
                            lineImage = const AssetImage('Assets/S8.png');
                          }
                        } else {
                          //bus logo, linie schreiben
                        }

                        return Center(
                          child: Column(
                            children:[
                              SizedBox(
                                width: 380,
                                height: 80,
                                child: Card(
                                  child: ListTile(
                                    leading: Image(
                                      image: lineImage,
                                        height: 40,
                                        width: 40,
                                      ),
                                      title: Text(
                                        style: deststyle,
                                        maxLines: 1,
                                        departure.destination),
                                    subtitle: Text(
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: timecolor,
                                      ),
                                      deptime
                                    ), 
                                    trailing: const Icon(
                                      size: 25,
                                      Icons.keyboard_arrow_down_rounded
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
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;                          //Zugriff nur auf current, da er nicht mehr braucht

   IconData LikeIcon;
    if (appState.favorites.contains(pair)) {
      LikeIcon = Icons.favorite;
    } else {
      LikeIcon = Icons.favorite_border;
    }

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('A random idea:'),
            RandomBox(pair: pair),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(onPressed: () {
                  appState.toggleFavorite();                             //Aktionen
                }, 
                icon: Icon(LikeIcon),
                label: Text('Like')),
                SizedBox(width: 10),
                
                
                ElevatedButton(onPressed: () {
                  appState.GetNext();                             //Aktionen
                }, 
                child: Text('Next')),
               
              ],
            )                              //Design
          ],
        ),
      );
  }
}

class GewerbePage extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return const Scaffold(

    );
  }
}

class BelaPage extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return const Scaffold(

    );
  }
}

class RandomBox extends StatelessWidget {
  const RandomBox({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(pair.asLowerCase, style: style,),
      ),
    );
  }
}
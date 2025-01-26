import 'package:eichwalde_app/Gewerbe.dart';
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

  factory VBBApiResponse.fromJson(Map<String, dynamic> json) {
    return VBBApiResponse(
      departures: List.from(json['departures'].map((x) => Departure.fromJson(x)),),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['realtimeDataUpdatedAt']),
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
    String lastUpdate = '';
    Timer? timer;
    int? expandedIndex;
    int? selectedindex;

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
  //evtl kein ausklappen
  //list sortieren nach zeit
  //benachrichtigung (Wecker)
  //appicon
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
                          );
                          deptime = 'Fahrt fällt aus';
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
                        var subtitlecol;
                        if (expanded) {
                          tileheight = 160;
                          arrow = Icons.keyboard_arrow_up_rounded;
                          linecount = 2;
                          subtitlecol = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: timecolor,
                                ),
                                deptime
                              ), 
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                'Gleis: ${departure.platform}'
                              ), 
                            ],
                          );
                        } else {
                          tileheight = 80;
                          arrow = Icons.keyboard_arrow_down_rounded;
                          linecount = 1;
                          subtitlecol = Text(
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: timecolor,
                                      ),
                                      deptime
                          );
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
                                    subtitle: subtitlecol,
                                    // subtitle: Text(
                                    //   style: TextStyle(
                                    //     fontSize: 15,
                                    //     color: timecolor,
                                    //   ),
                                    //   deptime
                                    // ), 
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

class GewerbePage extends StatefulWidget {

  @override
  State<GewerbePage> createState() => _GewerbePageState();
}

class _GewerbePageState extends State<GewerbePage> {

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(
          'Gewerbe',
          style: TextStyle(
            color: Color.fromRGBO(150, 200, 150, 1),
            fontSize:40,
            fontWeight: FontWeight.w500,
            letterSpacing:4.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        child: ListView.builder(
          physics: ClampingScrollPhysics(),
          itemCount: gewerbes.length,
          itemBuilder: (BuildContext context, int index){
            return ListTile(
              title: Text(gewerbes[index].Name),
              subtitle: Text(gewerbes[index].Gewerbeart),
              trailing: Card(
                child: Text('Tel.: +' + gewerbes[index].Tel.toString() + '\nAdr.:' + gewerbes[index].Adresse),

              )

            );
          },         
          ),
      ),  
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
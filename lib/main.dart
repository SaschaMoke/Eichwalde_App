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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //init notifications
  NotificationService().initNotification();
  
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
  //list sortieren nach zeit (evtl. geschafft)
  //fahrt fällt aus schöner machen! (evtl. auch fertig)
  //benachrichtigung (Wecker)
  //appicon
  Future<void> fetchAndUpdateData() async {
    try {
      final response = await http.get(
        Uri.parse('https://v6.vbb.transport.rest/stops/900260004/departures?linesOfStops=false&remarks=false&duration=60'),
      );

      if (response.statusCode == 200) {
        final apiResponse = VBBApiResponse.fromJson(jsonDecode(response.body));
        departures.sort((a, b) => a.when.compareTo(b.when));
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
            Center(
              child: ElevatedButton(
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
            ),

            //scheduled Notification
            //id muss fortlaufend gespeichert werden (entspricht anzahl an timern)
            //zudem müssen die timer gespeichert bleiben
            Center(
              child: ElevatedButton(
                onPressed: () {
                  fetchAndUpdateData();

                  NotificationService().scheduleNotification(
                    title: "Nächste Abfahrten in Eichwalde:",  //dynmaisch!
                    body: 
'''${departures[0].line}  ${departures[0].destination}  ${departures[0].when.substring(11,16)}                    
${departures[1].line}  ${departures[1].destination}  ${departures[1].when.substring(11,16)}
${departures[2].line}  ${departures[2].destination}  ${departures[2].when.substring(11,16)}''',
                    hour: 10,
                    minute: 11,
                  );
                }, 
                child: const Text('Send Notification')
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
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(onPressed: () {
                  appState.toggleFavorite();                             //Aktionen
                }, 
                icon: Icon(LikeIcon),
                label: const Text('Like')),
                const SizedBox(width: 10),
                
                
                ElevatedButton(onPressed: () {
                  appState.GetNext();                             //Aktionen
                }, 
                child: const Text('Next')),
               
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
      body: ListView.custom(childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
            return Card(
              borderOnForeground: true,
              elevation: 5,
              shadowColor: Color.fromRGBO(150, 200, 150, 1),
              child: ListTile(
              leading: Image(
                image: AssetImage(gewerbes[index].image),
                ),
              title: Text(gewerbes[index].name),
              subtitle: Text('Tel.: +' + gewerbes[index].tel.toString() + '\nAdr.:' + gewerbes[index].adresse),
              trailing: Text(gewerbes[index].gewerbeart),
              

              ),
            );
            },
            childCount: gewerbes.length, 
          ),
      ), 
       
       
       //grobes Layout, wie ich das am Donnerstag versucht habe zu erklären. Wäre halt die Frage, wie man
       //auch die rechte Spalte mit reinbekommt. 
       //So könnte man zum ausklappen dann halt die ganze Seitenbreite für ein Gewerbe nehmen, wenn man es ausklappt
       
       /* ListView.builder(
          itemCount: gewerbes.length,
          itemBuilder: (context, index) {
            return Column(
              
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 200,
                      height: 250,
                      child: Card(
                        color: Color.fromARGB(255, 150, 200, 150),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 180,
                              height: 150,
                              child: Image(
                                image: AssetImage(gewerbes[index].image)
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              //textAlign: TextAlign.start,
                              gewerbes[index].name,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 200,
                      height: 250,
                      child: Card(
                        color: Color.fromARGB(255, 150, 200, 150),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        )*/



      ); 
  }
}

class BelaPage extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return Scaffold(

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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

//File Imports:
import 'Gewerbe/gewerbeseite.dart';
import 'package:eichwalde_app/settings.dart';
import 'package:eichwalde_app/Design/eichwalde_design.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eichwalde_app/Read%20data/get_gewerbe_name.dart';
import 'package:eichwalde_app/Read%20data/get_gewerbe_image.dart';
import 'package:eichwalde_app/Read%20data/get_gewerbe_art.dart';
import 'package:eichwalde_app/Read%20data/get_gewerbe_adresse.dart';
import 'package:eichwalde_app/Read%20data/get_gewerbe_tel.dart';
import 'cloudgewerbe.dart';

import 'newscloud.dart';
import 'cloudtermine.dart';
import 'package:eichwalde_app/Verkehr/verkehrspage.dart';

/*Unused Files:
import 'package:eichwalde_app/notification_service.dart';
import 'Gewerbecloud.dart';
import 'package:eichwalde_app/gewerbe_layout_neu.dart';
import 'package:eichwalde_app/vbb_api.dart';

Unused packages:
import 'package:english_words/english_words.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
*/

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
 
  //NotificationService().initNotification();   //init notifications
  initializeDateFormatting('de_DE', null);      // Deutsch aktivieren
  loadSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Eichwalde',
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

}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  String pagename = '';
  Color indicatorColor = eichwaldeGradientGreen;
  Color indicatorColorLight = const Color.fromARGB(100, 80, 175, 50);

  @override
  Widget build(BuildContext context) {
    Widget page = Homepage();
    switch (selectedIndex) {
      case 0:
        page = Homepage();
        pagename = 'Home';
        indicatorColor = eichwaldeGradientGreen;
        indicatorColorLight = const Color.fromARGB(100, 80, 175, 50);
        break;
      case 1:
        page = Verkehrspage();
        pagename = 'Verkehr';
        indicatorColor = const Color.fromARGB(255, 60, 150, 80);
        indicatorColorLight = const Color.fromARGB(100, 60, 150, 80);
        break;
      case 2:
        page = GewerbePage();
        pagename = 'Gewerbe';
        indicatorColor = const Color.fromARGB(255, 35, 120, 110);
        indicatorColorLight = const Color.fromARGB(100, 35, 120, 110);
        //page = GewerbeLayoutNeu();
        break;
      case 3:
        //page = Terminepage();
        pagename = 'Termine';
        indicatorColor = const Color.fromARGB(255, 20, 100, 130);
        indicatorColorLight = const Color.fromARGB(100, 20, 100, 130);
        break;
      case 4:
        page = SettingsPage();
        pagename = 'Einstellungen';
        indicatorColor = eichwaldeGradientBlue;
        indicatorColorLight = const Color.fromARGB(100, 0, 80, 160);
        //page = AdminCheckPage();
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
            ),
          ),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            //backgroundColor: Color.fromRGBO(150, 200, 150, 1),
            //backgroundColor: eichwaldeGreen,    => etwas heller & Text/Icons weiß
            //backgroundColor: Colors.grey[50],
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            indicatorColor: indicatorColorLight,
            indicatorShape: RoundedRectangleBorder(
              side: BorderSide(
                color: indicatorColor,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(16)
            ),
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
                label: 'Admin', //=> Einstellungen
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.06,                
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.08,   
                    width: MediaQuery.of(context).size.width*0.175,   
                    child: Image(
                      image: const AssetImage('Assets/IconEichwalde.png'),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width*0.1,
                      fontWeight: FontWeight.bold,
                    ),
                    pagename
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                child: page
              )
            ],
          ),
        ),
      );
    });
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  final Cloudnews cloudNews = Cloudnews();
  final CollectionReference newsCollection = FirebaseFirestore.instance.collection('News');

  @override
  Widget build(BuildContext context) {
      return Column(
        children: [
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
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
            //print("Daten aus Firestore: $data");
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
                    (data['titel'] != null && data['titel'].toString().trim().isNotEmpty)
                        ? data['titel']
                        : "Ohne Titel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Tippe, um mehr zu lesen"),
                  shape: Border(),
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
    );
  }
}

class AdminCheckPage extends StatefulWidget {
  const AdminCheckPage({super.key});

  @override
  State<AdminCheckPage> createState() => _AdminCheckPageState();
}

//CODE FORMATIEREN (aber kommt ja wahrscheinlich auch weg)
class _AdminCheckPageState extends State<AdminCheckPage> {
  bool obscureText = true;

  void updateEingabe(String text) {
    if (text == '1234') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.5,
                width: MediaQuery.of(context).size.width*0.95,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 150, 200, 150),
                  border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(20)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        SizedBox(
                          height: constraints.maxHeight*0.1,
                        ),
                        SizedBox(
                          width: constraints.maxWidth*0.9,
                          child: Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: constraints.maxHeight*0.055
                            ),
                            'Bitte geben Sie das Password ein, um in den Admin-Bereich zu gelangen:'
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight*0.15,
                        ),
                        TextField(
                          obscureText: obscureText,
                          onSubmitted: updateEingabe,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                            ),
                            fillColor: Color.fromARGB(255, 235, 235, 235),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight*0.12,
                              maxWidth: constraints.maxWidth*0.95,
                            ),
                            labelText: 'Passwort'
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
      ]
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
      body:Center(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.02,                
                  ),
                  BackButton(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.02,                
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
                    'Admin',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.025,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.3,
                width: MediaQuery.of(context).size.width*0.95,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                  return Column(
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: constraints.maxWidth*0.06,
                          fontWeight: FontWeight.bold,
                        ),
                        'Termine am ${DateFormat('dd.MM.yyyy').format(DateTime.now())}:'
                      ),
                      Container(
                        height: constraints.maxHeight*0.75,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 150, 200, 150),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)
                          ),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: cloudTermine.getTermineForDate(DateTime.now()), // Termine für das heutige Datum laden
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(child: Text("Fehler beim Laden der Termine: ${snapshot.error}"));
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  style: TextStyle(
                                    fontSize: 20
                                  ),
                                  "Keine Termine gefunden"
                                )
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: ListView(
                                key: ValueKey(DateTime.now()),
                                children: snapshot.data!.docs.map((doc) {
                                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                         
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text("${data['name']} - ${data['service']}"),
                                    subtitle: Text("Uhrzeit: ${data['time']}"),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteTermin(doc.id),
                                    ),
                                  ),
                                );
                                }).toList(),
                              ),
                            );
                          }
                        ),

                      ),
                    ],
                  );
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.01,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.15,
                width: MediaQuery.of(context).size.width*0.95,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                  return Column(
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: constraints.maxWidth*0.06,
                          fontWeight: FontWeight.bold,
                        ),
                        'News'
                      ),
                      Container(
                        height: constraints.maxHeight*0.7,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 150, 200, 150),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)
                          ),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AdminNewsHinzufuegenPage()),
                              );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.add_outlined),
                                  SizedBox(width: 5),
                                  Text('Hinzufügen'),
                                ],
                              )
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.025,
                            ),
                            ElevatedButton(
                              onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NewsLoeschenPage()),
                              );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 5),
                                  Text('Löschen'),
                                ],
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.05,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.2,
                width: MediaQuery.of(context).size.width*0.95,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                  return Column(
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: constraints.maxWidth*0.06,
                          fontWeight: FontWeight.bold,
                        ),
                        'Gewerbe'
                      ),
                      Container(
                        height: constraints.maxHeight*0.7,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 150, 200, 150),
                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)
                          ),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GewerbeHinzufuegenPage()),
                                  );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_outlined),
                                      SizedBox(width: 5),
                                      Text('Hinzufügen'),
                                    ],
                                  )
                                ),
                                SizedBox(
                                  width: constraints.maxWidth*0.025,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GewerbeBearbeitenPage()),
                                  );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 5),
                                      Text('Bearbeiten'),
                                    ],
                                  )
                                ),
                              ],
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.025,
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.35,
                              child: ElevatedButton(
                                onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => GewerbeLoeschenPage()),
                                );
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline),
                                    SizedBox(width: 5),
                                    Text('Löschen'),
                                  ],
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                  },
                ),
              ),
            ]
          )
        ),
      )
    );
    
   
    /*return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body:Column(children: [
         StreamBuilder<QuerySnapshot>(
        stream: cloudTermine.getTermineForDate(DateTime.now()), // Termine für das heutige Datum laden
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
           return Center(child: Text("Fehler beim Laden der Termine: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Keine Termine gefunden"));
          }

         return SizedBox(
            height: 500,
           child: Expanded(
                      child: ListView(
                     key: ValueKey(DateTime.now()),
                      children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
           
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 4,
                        child: ListTile(
                          title: Text("${data['name']} - ${data['service']}"),
                          subtitle: Text("Uhrzeit: ${data['time']}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTermin(doc.id),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ),
         );
                }
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
                MaterialPageRoute(builder: (context) => GewerbeBearbeitenPage()),
              );
            },
            child: Text('Gewerbe bearbeiten')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminNewsHinzufuegenPage()),
              );
            },
            child: Text('News hinzufügen')),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsLoeschenPage()),
              );
            },
            child: Text('News löschen')),
      ]
      ),
      );*/
  }
}

class NewsLoeschenPage extends StatefulWidget {
  const NewsLoeschenPage({super.key});

  @override
  State<NewsLoeschenPage> createState() => _NewsLoeschenPageState();
}

class _NewsLoeschenPageState extends State<NewsLoeschenPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gewerbeartController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final Cloudnews cloudNews = Cloudnews();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("News löschen")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('News').snapshots(),
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
            return Center(child: Text('Keine News gefunden'));
          }

          var docs = snapshot.data!.docs;
          //print("Daten empfangen: ${docs.length} Gewerbe");

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              //print("Dokument ${index + 1}: ${docs[index].id}");

              return ListTile(
                title:  Text(
                  (docs[index].data() as Map<String, dynamic>?)?['titel'] ?? "Kein Titel",
                ),
                leading: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirmDelete = await _showDeleteDialog(context);
                    if (confirmDelete) {
                      await FirebaseFirestore.instance
                          .collection('News')
                          .doc(docs[index].id)
                          .delete();
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
}

Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Löschen bestätigen"),
            content: Text("Möchtest du diese News wirklich löschen?"),
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
    String name = nameController.text.trim();
    String gewerbeart = gewerbeartController.text.trim();
    String? adresse = adresseController.text.trim();
    int? tel = int.tryParse(telController.text.trim());
    String image = imageController.text.trim();
    
     if (image.isEmpty) {
      image = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Wappen_Eichwalde.svg/1200px-Wappen_Eichwalde.svg.png";
    }

    if (name.isNotEmpty &&
        gewerbeart.isNotEmpty ) {
      await cloudGewerbe.addGewerbe(name, gewerbeart, adresse, tel ?? 0, image);

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
      appBar: AppBar(title: Text("Gewerbe hinzufügen")),
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

extension on int {
  Null get isNotEmpty => null;
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
      appBar: AppBar(title: Text("Gewerbe löschen")),
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

class GewerbeBearbeitenPage extends StatelessWidget {
  const GewerbeBearbeitenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gewerbe bearbeiten"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Gewerbe').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Keine Gewerbe gefunden"));
          }

          var gewerbeList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gewerbeList.length,
            itemBuilder: (context, index) {
              var gewerbe = gewerbeList[index];
              var data = gewerbe.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['name'] ?? "Unbenannt"),
                  subtitle: Text(data['gewerbeart'] ?? "Keine Art angegeben"),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GewerbeEditForm(
                            docId: gewerbe.id,
                            data: data,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class GewerbeEditForm extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const GewerbeEditForm({super.key, required this.docId, required this.data});

  @override
  _GewerbeEditFormState createState() => _GewerbeEditFormState();
}

class _GewerbeEditFormState extends State<GewerbeEditForm> {
  late TextEditingController nameController;
  late TextEditingController artController;
  late TextEditingController adresseController;
  late TextEditingController telController;
  late TextEditingController imageController;

  final Cloudgewerbe cloudGewerbe = Cloudgewerbe();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    artController = TextEditingController(text: widget.data['gewerbeart']);
    adresseController = TextEditingController(text: widget.data['adresse']);
    telController = TextEditingController(text: widget.data['tel'].toString());
    imageController = TextEditingController(text: widget.data['image']);
  }

  @override
  void dispose() {
    nameController.dispose();
    artController.dispose();
    adresseController.dispose();
    telController.dispose();
    imageController.dispose();
    super.dispose();
  }

  void _updateGewerbe() {
    cloudGewerbe.updateGewerbe(
      widget.docId,
      nameController.text,
      artController.text,
      adresseController.text,
      int.tryParse(telController.text) ?? 0,
      imageController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gewerbe erfolgreich aktualisiert")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gewerbe bearbeiten"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: artController, decoration: InputDecoration(labelText: "Gewerbeart")),
            TextField(controller: adresseController, decoration: InputDecoration(labelText: "Adresse")),
            TextField(controller: telController, decoration: InputDecoration(labelText: "Telefon"), keyboardType: TextInputType.number),
            TextField(controller: imageController, decoration: InputDecoration(labelText: "Bild-URL")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateGewerbe,
              child: Text("Speichern"),
            ),
          ],
        ),
      ),
    );
  }
}

class GewerbePage extends StatefulWidget {
  const GewerbePage({super.key});

  @override
  State<GewerbePage> createState() => _GewerbePageState();
}

//CODE FORMATIEREN
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
    return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Gewerbeseite()),
                );
              },
              child: Text('Test neue Seite'),              
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.725,
              child: FutureBuilder(
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
              }),
            )
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
      ]
    );
  }
}

class Terminepage extends StatefulWidget {
  const Terminepage({super.key});

  @override
  _TerminepageState createState() => _TerminepageState();
}

class _TerminepageState extends State<Terminepage> {
  final CloudTermine cloudTermine = CloudTermine(); // Instanz von CloudTermine

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedService = "Einwohnermeldeamt";
  final List<String> _services = [
    "Einwohnermeldeamt",
    "Abholung Ausweis/Pass",
    "Standesamt",
    "Sachgebiet Bildung und Soziales"
  ];
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Column(
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
            );
          
      //braucht glaube ich das scaffold, aber soll ja eh weg

      /*floatingActionButton: FloatingActionButton(
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
  }*/
  }
}

/*child: LayoutBuilder(
  builder: (context, constraints) {
    return Column(
      children: [   
                                
      ],
    );
  }
),*/
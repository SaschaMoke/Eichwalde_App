import 'package:flutter/material.dart';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

//App-Files
import 'package:eichwalde_app/newscloud.dart';
import 'Design/eichwalde_design.dart';
import 'Gewerbe/Gewerbe_Module/Tools/pdf_viewer.dart';

Future<void> showUpdateLog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final currentVersion = '1.0';
  final lastVersion = prefs.getString('appVersion') ?? currentVersion;

  if (lastVersion != currentVersion) {
    await showModalBottomSheet(
      context: context, 
      showDragHandle: true,
      builder:(context) {
        Size constraints = MediaQuery.of(context).size;

        return Padding(
          padding: const EdgeInsets.fromLTRB(10,0,10,10),
          child: Column(
            children: [
              Row(
                children: [
                  Image(
                    width: constraints.width*0.225,
                    image: eichwaldeLogo,
                  ),
                  SizedBox(
                    width: constraints.width*0.025,
                  ),
                  Text(
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: constraints.width*0.075,
                    ),
                    'Neues in der App'
                  ),
                ],
              ),
              const SizedBox(height: 10),
              EichwaldeGradientBar(),
              const SizedBox(height: 10),
              SizedBox(
                height: constraints.height*0.4,
                child: ListView(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: constraints.width*0.04),
                        Container(
                          height: constraints.width*0.03,
                          width: constraints.width*0.03,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 0, 0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: constraints.width*0.025),
                        SizedBox(
                          width: constraints.width*0.815,
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: constraints.width*0.04,
                            ),
                            'Neue Funktion xy aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: constraints.width*0.04),
                        Container(
                          height: constraints.width*0.03,
                          width: constraints.width*0.03,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 0, 0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: constraints.width*0.025),
                        SizedBox(
                          width: constraints.width*0.815,
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: constraints.width*0.04,
                            ),
                            'Neue Funktion xy '
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    await prefs.setString('appVersion', currentVersion);
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showUpdateLog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: MediaQuery.of(context).size.height*0.745,
          width: constraints.maxWidth*0.95,
          child: ListView(
            children: [   
              Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth*0.025,
                  ),
                  Text(
                    style: TextStyle(
                      fontSize: constraints.maxWidth*0.09,
                      fontWeight: FontWeight.w500,
                    ),
                    'Newsletter'
                  ),
                ],
              ), 
              SizedBox(
                height: 150,
                width: constraints.maxWidth*0.95,
                child: Card(
                  surfaceTintColor: eichwaldeGreen,
                  elevation: 3,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      width: 3,
                      color: eichwaldeGreen,
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.newspaper_rounded),
                        title: Text('Newsletter Beispiel'),
                        trailing: IconButton(
                          onPressed: () => Navigator.push(context, 
                            MaterialPageRoute(
                              builder: (_) => PDFViewer(
                                constraints: constraints, 
                                url: 'https://www.eichwalde.de/wp-content/uploads/2025/05/Newsletter-Ausgabe-1_2025.pdf',
                                title: 'Test',
                              ),
                            ), 
                          ),
                          icon: Icon(Icons.preview_rounded)
                        ),
                      ),
                    ),
                  )
                ),
              ),
              const SizedBox(height: 15),
              EichwaldeGradientBar(),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth*0.025,
                  ),
                  Text(
                    style: TextStyle(
                      fontSize: constraints.maxWidth*0.09,
                      fontWeight: FontWeight.w500,
                    ),
                    'Aktuelles'
                  ),
                ],
              ),
              SizedBox(
                height: 300,
                width: constraints.maxWidth*0.95,
                child: Card(
                  surfaceTintColor: eichwaldeGreen,
                  elevation: 3,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      width: 3,
                      color: eichwaldeGreen,
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
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
                          children: snapshot.data!.docs.map((doc) {Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ExpansionTile(
                                leading: data['foto'] != null && data['foto'].isNotEmpty ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(data['foto'], width: 50, height: 50, fit: BoxFit.cover),
                                ): Icon(Icons.image, size: 50),
                                title: Text(
                                  (data['titel'] != null && data['titel'].toString().trim().isNotEmpty) ? data['titel']: "Ohne Titel",
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
                  )
                ),
              ),
            ],
          )
        );
      },
    );

      /*return Column(
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
    );*/
  }
}

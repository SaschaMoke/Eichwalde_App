import 'package:flutter/material.dart';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';

//App-Files
import 'package:eichwalde_app/newscloud.dart';
import 'Design/eichwalde_design.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: MediaQuery.of(context).size.height*0.7,
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

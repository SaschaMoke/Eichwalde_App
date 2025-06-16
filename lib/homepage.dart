import 'package:eichwalde_app/News/newsseite.dart';
import 'package:flutter/material.dart';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

//App-Files
//import 'package:eichwalde_app/newscloud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Design/eichwalde_design.dart';
import 'Gewerbe/Gewerbe_Module/Tools/pdf_viewer.dart';
import 'settings.dart' as appsettings;
import 'package:eichwalde_app/Gewerbe/Gewerbe_Module/Tools/urllauncher.dart';

//"homepage.dart" umbenennen zu "news.dart", neue homepage datei

class NewsList{
  String title;
  String date;
  String previewImg;
  String docID;

  NewsList({
    required this.title,
    required this.date,
    required this.previewImg,
    required this.docID,
  });
}

Future<void> showUpdateLog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final currentVersion = '1.0';
  final lastVersion = prefs.getString('appVersion') ?? '1.0';

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
  return;
}

Future<void> showMessage(BuildContext context) async {
  bool forceRepeat;
  bool showMessage;
  String messageContent;
  String messageTitle;
  bool moreInfo;
  String moreInfoLink;
  int messageID;

  try {
    final docSnapshot = await FirebaseFirestore.instance.collection('Message').doc('appMessage').get();
    final data = docSnapshot.data();

    if (data != null) {
      forceRepeat = data['forceRepeat']; 
      messageContent = data['messageContent']; 
      messageTitle = data['messageTitle']; 
      moreInfo = data['moreInfo']; 
      moreInfoLink = data['moreInfoLink']; 
      messageID = data['ID']; 
      showMessage = data['showMessage'];
    } else { 
      return;
    }
  } catch(e) {
    return;
  }
  
  if (showMessage) {
    final prefs = await SharedPreferences.getInstance();
    final lastMessage = prefs.getInt('messageID') ?? messageID+1;

    if (lastMessage != messageID) {
      await showModalBottomSheet(
        context: context, 
        isDismissible: false,
        enableDrag: false,
        builder:(context) {
          Size constraints = MediaQuery.of(context).size;

          return Padding(
            padding: const EdgeInsets.all(10),
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
                        fontSize: constraints.width*0.085,
                      ),
                      'Information',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                EichwaldeGradientBar(),
                const SizedBox(height: 10),
                SizedBox(
                  height: constraints.height*0.35,
                  child: ListView(
                    children: [
                      SizedBox(
                        width: constraints.width*0.9,
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: constraints.width*0.065,
                          ),
                          messageTitle,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: constraints.width*0.9,
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: constraints.width*0.035,
                          ),
                          messageContent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (moreInfo) TextButton(
                        onPressed: () async {
                          final Uri url =  Uri.parse(moreInfoLink);
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }, 
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(eichwaldeGreen)
                        ),
                        child: Text(
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: constraints.width*0.05,
                          ),
                          'Mehr Informationen'
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                EichwaldeGradientBar(),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  style: ButtonStyle(
                    fixedSize: WidgetStatePropertyAll(Size.fromWidth(constraints.width*0.85)),
                    backgroundColor: WidgetStatePropertyAll(eichwaldeGreen)
                  ),
                  child: Text(
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: constraints.width*0.05,
                    ),
                    'Fortfahren'
                  ),
                )
              ],
            ),
          );
        },
      );

      if (!forceRepeat) {
        await prefs.setInt('messageID', messageID);
      }
    }
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //int selectedIndex = 0;

  //final Cloudnews cloudNews = Cloudnews();
  //final CollectionReference newsCollection = FirebaseFirestore.instance.collection('News');

  Future<void> showUpdateAndMessage(BuildContext context) async {
    await showUpdateLog(context);
    await Future.delayed(Duration(milliseconds: 300));
    await showMessage(context);
    appsettings.Settings.updateAndMessageNotShown = false;
  }

  @override
  void initState() {
    super.initState();
    appsettings.Settings.updateAndMessageNotShown ? WidgetsBinding.instance.addPostFrameCallback((_) {
      showUpdateAndMessage(context);
    }):null;
    loadNews();
  }

  List<NewsList> newsList = [];
  String newsletterLink = '';
  String newsletterEdition = '';

  Future<void> loadNews() async {
    final snapshot = await FirebaseFirestore.instance.collection('NewsEichwalde').get();
    final snapshotNewsletter = await FirebaseFirestore.instance.collection('Newsletter').doc('Eichwalde').get();
    final newsletterData = snapshotNewsletter.data();
    
    setState(() {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        newsList.add(
          NewsList(
            title: data['Title'], 
            date: data['Date'], 
            previewImg: data['Preview'],
            docID: doc.id,
          ),
        );
      }
      newsletterLink = newsletterData?['Link'];
      newsletterEdition = newsletterData?['Edition'];
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
              Padding(
                padding: EdgeInsets.only(left: constraints.maxWidth*0.025), 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize: constraints.maxWidth*0.09,
                            fontWeight: FontWeight.w500,
                          ),
                          'Newsletter'
                        ),
                        Text(
                          style: TextStyle(
                            height: 0.5,
                            fontSize: constraints.maxWidth*0.05,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                          'Ausgabe $newsletterEdition'
                        ),
                      ],
                    ),
                    SizedBox(
                      width: constraints.maxWidth*0.15,
                    ),
                    IconButton(
                      onPressed: () {
                        if (newsletterLink.isNotEmpty) {
                          Navigator.push(context, 
                            MaterialPageRoute(
                              builder: (_) => PDFViewer(
                                constraints: constraints, 
                                url: newsletterLink,
                                title: 'Test',
                              ),
                            ), 
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color.fromARGB(255, 200, 25, 0),
                              content: Text(
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.w500,
                                fontSize: constraints.maxWidth*0.035,
                              ),
                              'Fehler: Zurzeit ist kein Newsletter hinterlegt.'
                              )
                            )
                          );
                        } 
                      },
                      iconSize: constraints.maxWidth*0.085,
                      color: newsletterLink.isNotEmpty ? eichwaldeGreen: const Color.fromARGB(255, 200, 25, 0),
                      icon: const Icon(Icons.read_more_rounded),
                    ),
                    SizedBox(
                      width: constraints.maxWidth*0.025,
                    ),
                    IconButton(
                      onPressed: () async {
                        final Uri url =  Uri.parse('https://www.eichwalde.de/newsletter-archiv/');
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          showErrorBar(constraints, context);
                        }
                      },
                      iconSize: constraints.maxWidth*0.085,
                      color: eichwaldeGreen,
                      icon: const Icon(Icons.list_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              EichwaldeGradientBar(),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: constraints.maxWidth*0.025),
                child: Text(
                  style: TextStyle(
                    fontSize: constraints.maxWidth*0.09,
                    fontWeight: FontWeight.w500,
                  ),
                  'Aktuelles'
                ),
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
                    child: newsList.isNotEmpty ? ListView.builder(
                      itemCount: newsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = newsList[index];
                        
                        return Card(
                          child: ListTile(
                            leading: SizedBox(
                              width: constraints.maxWidth*0.1,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'Assets/IconEichwalde.png', 
                                image: item.previewImg,
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return Image(image: AssetImage('Assets/IconEichwalde.png'));
                                },
                              ),
                            ),
                            title: item.title.isNotEmpty ? Text(item.title):Text(style: TextStyle(fontStyle: FontStyle.italic), 'Kein Titel angegeben'),
                            subtitle: Text('Vom: ${item.date}'),
                            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => Newsseite(documentId: item.docID)),),
                          ),
                        );
                      },
                    ):Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ),
                        'Keine Neuigkeiten vorhanden'
                      ),
                    ),
                    
                    /*child: StreamBuilder<QuerySnapshot>(
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
                    ),*/
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

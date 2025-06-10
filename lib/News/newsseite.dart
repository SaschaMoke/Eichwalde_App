import 'package:flutter/material.dart';

//Packages
import 'package:cloud_firestore/cloud_firestore.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/settings.dart' as eichwalde_settings;

class NewsStructure{
  final String type;
  final String content;
  final String contentSimple;
  final int index;

  NewsStructure({
    required this.type,
    required this.content,
    required this.contentSimple,
    required this.index,
  });

  factory NewsStructure.fromMap(Map<String, dynamic> map) {
    return NewsStructure(
      type: map['type'] ?? '',
      content: map['content'] ?? '',
      contentSimple: map['contentSimple'] ?? '',
      index: map['index'] ?? 0,
    );
  }
}

class Newsseite extends StatefulWidget{
  final String documentId;
  
  const Newsseite({
    required this.documentId,
    super.key
  });

  @override
  State<Newsseite> createState() => _NewsseiteState();
}

//Bild: content ist Link, ContentSimple ist Untertitel

class _NewsseiteState extends State<Newsseite> {
  //test
  bool simpleAvailable = false;

  bool simpleLanguage = eichwalde_settings.Settings.simpleLanguage;
  String newsTitle = '';
  String newsAuthor = '';
  String newsDate = '';
  List<Widget> newsItems = [];

  Future<String> loadData(String docId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('NewsEichwalde').doc(docId).get();
      final data = docSnapshot.data();

      if (data != null) {
        newsTitle = data['Title'];
        newsAuthor = data['Author'];
        newsDate = data['Date'];

        final List<NewsStructure> newsSections = [];
        for (var entry in data.entries) {
          if (entry.value is Map<String, dynamic>) {
            final map = entry.value as Map<String, dynamic>;

            if (map.containsKey('type') && map.containsKey('content') && map.containsKey('index')) {
              newsSections.add(NewsStructure.fromMap(map));
              if (map['contentSimple'] != '' && map['type'] == 'text') simpleAvailable = true;
            }
          }
        }
        newsSections.sort((a, b) => a.index.compareTo(b.index));
        !simpleAvailable ? simpleLanguage = false:null;
        
        newsItems = [];
        for (var section in newsSections) {
          if (section.type == 'text') {
            newsItems.add(
              Text(
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width*0.04,
                ),
                simpleLanguage ? section.contentSimple:section.content, 
              ),
            );
          } else if (section.type == 'image') {
            newsItems.add(//entsprechend style anpassen
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: 'Assets/IconEichwalde.png', 
                    image: section.content,
                    imageErrorBuilder: (context, error, stackTrace) {
                       return Image(image: eichwaldeLogo);
                    },
                  ),
                  const SizedBox(height: 5),
                  Text(
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width*0.035,
                      fontStyle: FontStyle.italic,
                    ),
                    section.contentSimple, 
                  ),
                ],
              ),
            );
          }
          //evtl. weitere möglichkeiten
        }
        return '';
      } else {
        return 'hehe';
      }
    } catch(e) {
      print('Loading Error : $e');
      return 'hehe';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: loadData(widget.documentId),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.375,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: MediaQuery.of(context).size.width*0.035,
                              ),
                              'Leichte\nSprache'
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.025,
                            ),
                            Switch(
                              value: simpleAvailable ? simpleLanguage:false, 
                              onChanged: (bool value) {
                                setState(() {
                                  simpleLanguage = value;
                                });
                              },
                              activeColor: eichwaldeGreen,
                              inactiveThumbColor:const Color.fromARGB(255, 200, 25, 0),
                            ),
                          ],
                        ),
                      ),
                      if (!simpleAvailable) Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(125, 75, 75, 75),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: MediaQuery.of(context).size.width*0.035,
                            ),
                            'nicht verfügbar'
                          ),
                        ),
                      ),
                    ] 
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.025,
                ),
              ],
            ),
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.9,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: constraints.maxWidth*0.1
                          ),
                          newsTitle,
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: constraints.maxWidth*0.05,
                            fontStyle: FontStyle.italic,
                            height: constraints.maxWidth*0.0025,
                          ),
                          newsDate, 
                        ),
                        const SizedBox(height: 20),
                        EichwaldeGradientBar(),
                        const SizedBox(height: 20),
                        Column(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: newsItems,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}
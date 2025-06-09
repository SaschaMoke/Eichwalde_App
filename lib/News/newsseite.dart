import 'package:flutter/material.dart';

//Packages
//import 'package:cloud_firestore/cloud_firestore.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/settings.dart' as eichwalde_settings;

class Newsseite extends StatefulWidget{
  final String documentId;
  
  const Newsseite({
    required this.documentId,
    super.key
  });

  @override
  State<Newsseite> createState() => _NewsseiteState();
}

class _NewsseiteState extends State<Newsseite> {
  //test
  bool simpleAvailable = false;
  
  bool simpleLanguage = eichwalde_settings.Settings.simpleLanguage;

  @override
  Widget build(BuildContext context) {
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
                    'Titel',
                  ),
                  Text(
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: constraints.maxWidth*0.05,
                      fontStyle: FontStyle.italic,
                      height: constraints.maxWidth*0.0025,
                    ),
                    'Datum?', 
                  ),
                  const SizedBox(height: 20),
                  EichwaldeGradientBar(),
                  const SizedBox(height: 20),
                  Text(
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: constraints.maxWidth*0.05,
                    ),
                    simpleLanguage ? 'InhaltLeichtVariable':'InhaltNormalVar', 
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
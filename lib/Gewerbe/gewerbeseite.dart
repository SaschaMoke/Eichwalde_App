import 'package:eichwalde_app/Gewerbe/Gewerbe_Module/kontakt.dart';
import 'package:eichwalde_app/Gewerbe/Gewerbe_Module/social.dart';
import 'package:flutter/material.dart';
import 'Gewerbe_Module/oeffnung.dart';

class Gewerbeseite extends StatefulWidget{
  const Gewerbeseite({super.key});

  @override
  State<Gewerbeseite> createState() => _GewerbeseiteState();
}

class _GewerbeseiteState extends State<Gewerbeseite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi'),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: Icon(Icons.favorite_outline)
          )
        ],
      ),
      body: Center(       //evtl Center entfernen
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.9,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                children: [
                  SizedBox(height: 20),
                  Image.network(
                    'https://i.ytimg.com/vi/yzCtDA6tHLo/maxresdefault.jpg'
                  ),
                  SizedBox(height: 20),
                  Text(
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: constraints.maxWidth*0.1
                    ),
                    'Bertram GmbH'
                  ),
                  SizedBox(height: 20),
                  ExpansionTile(
                    leading: Icon(Icons.description_outlined), //evtl.
                    title: Text(
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: constraints.maxWidth*0.075,
                      ),
                      'Beschreibung'
                    ),
                    shape: const Border(),
                    tilePadding: EdgeInsets.all(1),
                    childrenPadding: EdgeInsets.all(5),
                    textColor: Color.fromARGB(255, 50, 150, 50),
                    iconColor: Color.fromARGB(255, 50, 150, 50), 
                    children: [
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: constraints.maxWidth*0.04
                        ),
                        'Lorem ipsum salami hallo ich bin ein langer Text um das mal ein bisschen zu füllen Bom schalom Schames lalala Moke bom'
                      )
                    ],
                  ),

                  //weitere Module hier drunter:
                  Oeffnungszeiten(
                    monday: '08:00 - 16:00 Uhr', 
                    tuesday: '08:00 - 16:00 Uhr', 
                    wednesday: '08:00 - 16:00 Uhr', 
                    thursday: '08:00 - 16:00 Uhr', 
                    friday: '08:00 - 16:00 Uhr', 
                    saturday: 'Geschlossen', 
                    sunday: 'Geschlossen', 
                    constraints: constraints,
                    leadingHint: 'Abweichende Öffnungszeiten durch Osterferien',
                    leadingImportant: true,
                    trailingHint: 'Bottom text',
                    trailingImportant: true,
                  ),
                  SocialMedia(
                    instagramName: 'Bertram0815',
                    facebookName: 'Bertram0815',
                    showFacebook: true,
                    showInstagram: true,
                    constraints: constraints
                  ),
                  Kontakt(
                    adresse: 'Bertramstraße 69',
                    web: 'bertram-website.de',
                    telefon: '+69 1234 56789',
                    mail: 'bertram@gmail.com',
                    constraints: constraints
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
    
    //return SafeArea(
      
      //child: child
    //);
  }
}
import 'package:flutter/material.dart';

//module
import 'Gewerbe_Module/oeffnung.dart';
import 'Gewerbe_Module/kontakt.dart';
import 'Gewerbe_Module/social.dart';
import 'Gewerbe_Module/restaurant.dart';

class Gewerbeseite extends StatefulWidget{
  const Gewerbeseite({super.key});

  @override
  State<Gewerbeseite> createState() => _GewerbeseiteState();
}

//alle Strings werden durch Firebasewerte ersetzt

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
                    'Bertram GmbH' //Gewerbename
                  ),
                  SizedBox(height: 20),
                  ExpansionTile(
                    leading: Icon(Icons.description_outlined),
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
                    initiallyExpanded: true,
                    children: [
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
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
                  Kontakt(
                    adresse: 'Bahnhofstraße 79, Eichwalde',
                    web: 'https://www.youtube.com/',
                    telefon: '+69 1234 56789',
                    mail: 'bertram@gmail.com',
                    constraints: constraints
                  ),
                  SocialMedia(
                    instagramName: 'Bertram0815',
                    facebookName: 'Bertram0815',
                    youtubeName: 'Bertram0815',
                    instagramLink: 'https://www.youtube.com/',
                    facebookLink: 'https://www.youtube.com/',
                    youtubeLink: 'https://www.youtube.com/',
                    ////////////entfernen
                    showFacebook: true,
                    showInstagram: true,
                    ////////////
                    constraints: constraints
                  ),
                  Restaurant(
                    telefon: '+69 1234 56789',
                    karte: 'https://pane-vino-eichwalde.de/wp-content/uploads/2024/02/Pane-Vino-Eichwalde-Speisekarte.pdf',
                    orderLink: 'xx',
                    gewerbeName: 'Bertrams Restaurant GmbH',//Gewerbename
                    constraints: constraints
                  ),  
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
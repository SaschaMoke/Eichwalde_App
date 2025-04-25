import 'package:flutter/material.dart';

//module
import 'Gewerbe_Module/oeffnung.dart';
import 'Gewerbe_Module/kontakt.dart';
import 'Gewerbe_Module/social.dart';
import 'Gewerbe_Module/restaurant.dart';
import 'Gewerbe_Module/bilder.dart';

class Gewerbeseite extends StatefulWidget{
  const Gewerbeseite({super.key});

  @override
  State<Gewerbeseite> createState() => _GewerbeseiteState();
}

//alle Strings werden beim Laden der seite durch die entsprechenden Firebasewerte ersetzt

class _GewerbeseiteState extends State<Gewerbeseite> {
  //(late, bzw. String?)
  
  String gewerbeName = ''; 
  String gewerbeBeschreibung = '';
  String gewerbeImage = '';

  bool kontaktModul = true;   //standard = false
  String kontaktTelefon = '';
  String kontaktMail = '';
  String kontaktWeb = '';
  String kontaktAdresse = '';
  
  bool oeffnungsModul = true;   //standard = false
  String oeffnungsMo = '';
  String oeffnungsDi = '';
  String oeffnungsMi = '';
  String oeffnungsDo = '';
  String oeffnungsFr = '';
  String oeffnungsSa = '';
  String oeffnungsSo = '';

  bool socialModul = true;   //standard = false
  String socialFacebookName = '';
  String socialFacebookLink = '';
  String socialInstagramName = '';
  String socialInstagramLink = '';
  String socialYoutubeName = '';
  String socialYoutubeLink = '';

  bool restaurantModul = true;   //standard = false
  String restaurantOrderLink = '';
  String restaurantKarte = '';
  String restaurantTelefon = '';

  bool bilderModul = true; //standard = false
  //nur beispiele
  String bilderLink1 = '';
  String bilderLink2 = '';
  String bilderLink3 = '';
  String bilderLink4 = '';
  String bilderLink5 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi'),
        actions: [
          IconButton(
            onPressed: () {}, //Favoritenoption hier
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
                    'https://i.ytimg.com/vi/yzCtDA6tHLo/maxresdefault.jpg'    //GewerbeImage
                  ),
                  SizedBox(height: 20),
                  Text(
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: constraints.maxWidth*0.1
                    ),
                    'Bertram GmbH'                                //Gewerbename
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
                      )         //Gewerbebeschreibung
                    ],
                  ),

                  //weitere Module hier drunter (reihenfolge festlegen!!):
                  oeffnungsModul ? Oeffnungszeiten(
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
                  ):SizedBox(),
                  kontaktModul ? Kontakt(
                    adresse: 'Bahnhofstraße 79, Eichwalde',
                    web: 'https://www.youtube.com/',
                    telefon: '+69 1234 56789',
                    mail: 'bertram@gmail.com',
                    constraints: constraints
                  ):SizedBox(),
                  socialModul ? SocialMedia(
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
                  ):SizedBox(),
                  restaurantModul ? Restaurant(
                    telefon: '+69 1234 56789',
                    karte: 'https://pane-vino-eichwalde.de/wp-content/uploads/2024/02/Pane-Vino-Eichwalde-Speisekarte.pdf',
                    orderLink: 'xx',
                    gewerbeName: 'Bertrams Restaurant GmbH',//Gewerbename
                    constraints: constraints
                  ):SizedBox(),  
                  bilderModul ? Bilder(
                    image1:'',
                    image2:'',
                    image3:'',
                    image4:'',
                    constraints: constraints
                  ):SizedBox(),
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
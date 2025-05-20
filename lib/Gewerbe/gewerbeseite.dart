import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:eichwalde_app/Design/eichwalde_design.dart';

//module
import 'Gewerbe_Module/oeffnung.dart';
import 'Gewerbe_Module/kontakt.dart';
import 'Gewerbe_Module/social.dart';
import 'Gewerbe_Module/restaurant.dart';
import 'Gewerbe_Module/bilder.dart';

class Gewerbeseite extends StatefulWidget{
  final String documentId;
  
  const Gewerbeseite({
    required this.documentId,
    super.key
  });

  @override
  State<Gewerbeseite> createState() => _GewerbeseiteState();
}

class _GewerbeseiteState extends State<Gewerbeseite> {
  String gewerbeName = ''; 
  String gewerbeBeschreibung = '';
  String gewerbeImage = '';
  String gewerbeKat = '';

  //bool kontaktModul = true;   //standard = false
  String kontaktActive = 'false';
  String kontaktTelefon = '';
  String kontaktMail = '';
  String kontaktWeb = '';
  String kontaktAdresse = '';
  
  //bool oeffnungsModul = true;   //standard = false
  String oeffnungActive = 'false';
  String oeffnungsMo = '';
  String oeffnungsDi = '';
  String oeffnungsMi = '';
  String oeffnungsDo = '';
  String oeffnungsFr = '';
  String oeffnungsSa = '';
  String oeffnungsSo = '';
  String oeffnungLeading = '';
  String oeffnungTrailing = '';
  String oeffnungLeadingImportant = 'false';
  String oeffnungTrailingImportant = 'false';

  //bool socialModul = true;   //standard = false
  String socialActive = 'false';
  String socialFacebookName = '';
  String socialFacebookLink = '';
  String socialInstagramName = '';
  String socialInstagramLink = '';
  String socialYoutubeName = '';
  String socialYoutubeLink = '';

  bool restaurantModul = false;   //standard = false
  String restaurantActive = 'false';
  String restaurantOrderLink = '';
  String restaurantKarte = '';
  String restaurantTelefon = '';

  //bool bilderModul = true; //standard = false
  String bilderActive = 'false';
  //nur beispiele
  String bilderLink1 = '';
  String bilderLink2 = '';
  String bilderLink3 = '';
  String bilderLink4 = '';
  String bilderLink5 = '';

  Future<String> loadData(String docId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('Gewerbe2').doc(docId).get();
      final data = docSnapshot.data();

      if (data != null) {
        gewerbeName = data['name'];
        gewerbeBeschreibung = data['beschreibung'];
        gewerbeImage = data['bild'];
        gewerbeKat = data['kategorie'];

        oeffnungActive = data['oeffnung']['active'];
        oeffnungsMo = data['oeffnung']['mo'];
        oeffnungsDi = data['oeffnung']['di'];
        oeffnungsMi = data['oeffnung']['mi'];
        oeffnungsDo = data['oeffnung']['do'];
        oeffnungsFr = data['oeffnung']['fr'];
        oeffnungsSa = data['oeffnung']['sa'];
        oeffnungsSo = data['oeffnung']['so'];       
        oeffnungLeading = data['oeffnung']['textOben']['text'];
        oeffnungLeadingImportant = data['oeffnung']['textOben']['important'];
        oeffnungTrailing = data['oeffnung']['textUnten']['text'];
        oeffnungTrailingImportant = data['oeffnung']['textUnten']['important'];

        kontaktActive = data['kontakt']['active'];
        kontaktAdresse = data['kontakt']['adresse'];
        kontaktMail = data['kontakt']['mail'];
        kontaktTelefon = data['kontakt']['tel'];
        kontaktWeb = data['kontakt']['web'];

        socialActive = data['social']['active'];
        socialFacebookLink = data['social']['facebookLink'];
        socialFacebookName = data['social']['facebookName'];
        socialInstagramLink = data['social']['instagramLink'];
        socialInstagramName = data['social']['instagramName'];
        socialYoutubeLink = data['social']['youtubeLink'];
        socialYoutubeName = data['social']['youtubeName'];

        bilderActive = data['galerie']['active'];
        bilderLink1 = data['galerie']['bild1'];
        bilderLink2 = data['galerie']['bild2'];
        bilderLink3 = data['galerie']['bild3'];
        bilderLink4 = data['galerie']['bild4'];
        bilderLink5 = data['galerie']['bild5'];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi'),
        actions: [
          IconButton(
            onPressed: () {
              
            }, //Favoritenoption hier
            icon: const Icon(Icons.favorite_outline)        
          )
        ],
      ),
      body: FutureBuilder<String>(
        future: loadData(widget.documentId),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {  
          if (snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.9,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      children: [
                        const SizedBox(height: 20),
                        Image.network(
                          //'https://i.ytimg.com/vi/yzCtDA6tHLo/maxresdefault.jpg'    //GewerbeImage
                          gewerbeImage,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: constraints.maxWidth*0.1
                          ),
                          //'Bertram GmbH'                                //Gewerbename
                          gewerbeName,
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: constraints.maxWidth*0.05,
                            fontStyle: FontStyle.italic,
                            height: constraints.maxWidth*0.0025,
                          ),
                          //'Comedy',                                //Kategorie  
                          gewerbeKat, 
                        ),
                        const SizedBox(height: 20),
                        EichwaldeGradientBar(),
                        const SizedBox(height: 20),
                        ExpansionTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: constraints.maxWidth*0.075,
                            ),
                            'Beschreibung'
                          ),
                          shape: const Border(),
                          tilePadding: const EdgeInsets.all(1),
                          childrenPadding: const EdgeInsets.all(5),
                          textColor: eichwaldeGreen,
                          iconColor: eichwaldeGreen,
                          initiallyExpanded: true,
                          children: [
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: constraints.maxWidth*0.04
                              ),
                              //'Lorem ipsum salami hallo ich bin ein langer Text um das mal ein bisschen zu füllen Bom schalom Schames lalala Moke bom'
                              gewerbeBeschreibung,
                            )         //Gewerbebeschreibung
                          ],
                        ),
              
                        oeffnungActive == 'true' ? Oeffnungszeiten(
                          monday: oeffnungsMo,
                          tuesday: oeffnungsDi,
                          wednesday: oeffnungsMi,
                          thursday: oeffnungsDo,
                          friday: oeffnungsFr,
                          saturday: oeffnungsSa,
                          sunday: oeffnungsSo,
                          constraints: constraints,
                          leadingHint: oeffnungLeading,
                          leadingImportant: oeffnungLeadingImportant,
                          trailingHint: oeffnungTrailing,
                          trailingImportant: oeffnungTrailingImportant,
                        ):SizedBox(),
                        kontaktActive == 'true' ? Kontakt(
                          adresse: kontaktAdresse,
                          web: kontaktWeb,
                          telefon: kontaktTelefon,
                          mail: kontaktMail,
                          constraints: constraints
                        ):SizedBox(),
                        socialActive == 'true' ? SocialMedia(
                          instagramName: socialInstagramName,
                          facebookName: socialFacebookName,
                          youtubeName: socialYoutubeName,
                          instagramLink: socialInstagramLink,
                          facebookLink: socialFacebookLink,
                          youtubeLink: socialYoutubeLink,
                          constraints: constraints
                        ):SizedBox(),
                        restaurantModul ? Restaurant(                 //gewerbeData!['restaurant']['active'] == 'true'
                          telefon: '+69 1234 56789',
                          karte: 'https://pane-vino-eichwalde.de/wp-content/uploads/2024/02/Pane-Vino-Eichwalde-Speisekarte.pdf',
                          orderLink: 'xx',
                          gewerbeName: 'Bertrams Restaurant GmbH',//Gewerbename
                          constraints: constraints
                        ):SizedBox(),  
                        bilderActive == 'true' ? Bilder(
                          image1:'',
                          image2:'',
                          image3:'',
                          image4:'',
                          imageLinks: [
                            bilderLink1,
                            bilderLink2,
                            bilderLink3,
                            bilderLink4,
                            bilderLink5,
                          ],
                          imageCaptions: [
                            'Bertram', 
                            'Sascha Moke', 
                            'Bom', 
                            'Was zur Hölle mache ich hier eigentlich'
                          ],
                          constraints: constraints
                        ):SizedBox(),
              
                        //weitere Module hier drunter (reihenfolge festlegen!!):
                        /*oeffnungsModul ? Oeffnungszeiten(
                          monday: '08:00 - 16:00 Uhr', 
                          tuesday: '08:00 - 16:00 Uhr', 
                          wednesday: '08:00 - 16:00 Uhr', 
                          thursday: '08:00 - 16:00 Uhr', 
                          friday: '08:00 - 16:00 Uhr', 
                          saturday: 'Geschlossen', 
                          sunday: 'Geschlossen', 
                          constraints: constraints,
                          leadingHint: 'Abweichende Öffnungszeiten durch Osterferien',
                          leadingImportant: 'true',
                          trailingHint: 'Bottom text',
                          trailingImportant: 'true',
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
                          imageLinks: [
                            'https://image.stern.de/33801218/t/SL/v1/w1440/r1.3333/-/bild-person-der-woche--olaf-scholz.jpg',
                            'https://www.br.de/puls/amthor-memes-102~_v-img__16__9__l_-1dc0e8f74459dd04c91a0d45af4972b9069f1135.jpg?version=0cab2',
                            'https://www.rheinpfalz.de/cms_media/module_img/11740/5870071_1_org_5faa040070584568.webp',
                            'https://www.merkur.de/assets/images/27/25/27025125-markus-soeder-hat-am-montag-beim-gillamoos-fruehschoppen-die-konkurrenz-ins-visier-genommen-3pe9.jpg',
                          ],
                          imageCaptions: [
                            'Bertram', 
                            'Sascha Moke', 
                            'Bom', 
                            'Was zur Hölle mache ich hier eigentlich'
                          ],
                          constraints: constraints
                        ):SizedBox(),*/
                        Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: constraints.maxWidth*0.03
                          ),
                          '''Alle Angaben ohne Gewähr. Keine Garantie für Aktualität und Richtigkeit.'''
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
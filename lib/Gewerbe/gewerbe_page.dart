import 'package:flutter/material.dart';

//App-Files
import 'package:eichwalde_app/Gewerbe/gewerbeseite.dart';
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/cloudgewerbe.dart';

//import 'package:eichwalde_app/Read%20data/get_gewerbe_adresse.dart';
//import 'package:eichwalde_app/Read%20data/get_gewerbe_art.dart';
//import 'package:eichwalde_app/Read%20data/get_gewerbe_tel.dart';

class GewerbePage extends StatefulWidget {
  const GewerbePage({super.key});

  @override
  State<GewerbePage> createState() => _GewerbePageState();
}

//CODE FORMATIEREN
class _GewerbePageState extends State<GewerbePage> {
  final Cloudgewerbe cloudGewerbe = Cloudgewerbe();

  List<GewerbeModel> gewerbeFilteredListe = [];
  List<GewerbeModel> gewerbeSearchedListe = [];
  TextEditingController searchController = TextEditingController();

  Set<String> filterKategorien = {};
  bool filterFavoriten = false;
  bool filterAlle = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<bool> expandableState = List.generate(gewerbes.length, (index) => false);
    final gewerbeKategorien = cloudGewerbe.gewerbeListe.map((x) => x.kategorie).toSet().toList();
    gewerbeKategorien.sort((a, b) {
      final aAktiv = filterKategorien.contains(a);
      final bAktiv = filterKategorien.contains(b);

      if (aAktiv && !bAktiv) return -1;
      if (!aAktiv && bAktiv) return 1;
      return a.compareTo(b); // alphabetisch innerhalb Gruppen
    });

    //gewerbeFilteredListe = cloudGewerbe.gewerbeListe;//temp
    gewerbeFilteredListe = cloudGewerbe.gewerbeListe.where((gewerbe) {
      if (filterAlle) return true;

      final filteredKategorie = filterKategorien.contains(gewerbe.kategorie);
      //final istFavorit = widget.favoritenIds.contains(gewerbe.id);

      //if (filterFavoriten && istFavorit) return true;
      if (filterKategorien.isNotEmpty && !filteredKategorie) return false;

      return true;
    }).toList();


    return SizedBox(
      width: MediaQuery.of(context).size.width*0.95,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {  
          return Column(
              children: [
                Row(
                  children: [
                    SearchBar(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth*0.8,
                        minHeight: 50,
                      ),
                      controller: searchController,
                      leading: const Icon(Icons.search_rounded),
                      hintText: 'Gewerbe suchen...',
                      elevation: const WidgetStatePropertyAll(0),
                      backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(0, 0, 0, 0)),
                      shape: WidgetStateProperty.fromMap(<WidgetStatesConstraint, OutlinedBorder>{
                        WidgetState.focused: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            width: 2,
                            color: eichwaldeGreen,
                          )
                        ),
                        WidgetState.any: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 100, 100, 100),
                          )
                        ),
                      }),
                      overlayColor: const WidgetStatePropertyAll(Color.fromARGB(0, 0, 0, 0)),
                      onChanged: (String value) {
                        setState(() {
                          gewerbeSearchedListe = gewerbeFilteredListe.where(
                            (element) => element.name.toLowerCase().contains(value.toLowerCase())
                          ).toList();
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: Icon(
                        Icons.filter_alt_off_outlined,
                        size: constraints.maxWidth*0.0625,
                      ), 
                      onSelected: (bool value) {
                        setState(() {
                          filterAlle = value;
                          filterKategorien.clear();
                          filterFavoriten = false;
                        });
                      },
                      selectedColor: Color.fromARGB(100, 50, 150, 50),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: eichwaldeGreen,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25)
                      ),
                      selected: filterAlle,
                      showCheckmark: false,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(//Filter
                  children: [
                    FilterChip(
                      label: Icon(
                        Icons.favorite_border_rounded,
                        size: constraints.maxWidth*0.0625,
                      ), 
                      onSelected: (bool value) {
                        setState(() {
                          filterFavoriten = value;
                          filterAlle = false;
                        });
                      },
                      selectedColor: Color.fromARGB(100, 50, 150, 50),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: eichwaldeGreen,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25)
                      ),
                      selected: filterFavoriten,
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      width: constraints.maxWidth*0.8,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var kategorie in gewerbeKategorien) 
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: FilterChip(
                                label: Text(kategorie), 
                                onSelected: (bool value) {
                                  setState(() {
                                    filterAlle = false;
                                    if (value) {
                                      filterKategorien.add(kategorie);
                                    } else {
                                      filterKategorien.remove(kategorie);
                                    }
                                  });
                                },
                                selectedColor: Color.fromARGB(100, 50, 150, 50),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: eichwaldeGreen,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(25)
                                ),
                                selected: filterKategorien.contains(kategorie),
                                showCheckmark: false,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.5,
                  child: FutureBuilder(
                    future: cloudGewerbe.getDocID(),
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(
                          color: eichwaldeGreen,
                        ));
                      }
                      
                      if (cloudGewerbe.gewerbeListe.isEmpty) {
                        return Center(
                          child: SizedBox(
                            width: constraints.maxWidth*0.85,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: constraints.maxWidth*0.15,
                                      color: Color.fromARGB(255, 255, 0, 0),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth*0.015,
                                    ),
                                    Text(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth*0.1,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 255, 0, 0)
                                      ),
                                      'Fehler'
                                    ),
                                  ],
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth*0.05,
                                  ),
                                  'Es konnten keine Daten geladen werden. Bitte überprüfen Sie Ihre Internetverbindung oder versuchen Sie es später nocheinmal.'
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (searchController.text.isEmpty || gewerbeSearchedListe.isNotEmpty) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 250,
                          ),
                          //itemCount: cloudGewerbe.gewerbeListe.length,
                          itemCount: searchController.text.isNotEmpty ? gewerbeSearchedListe.length:gewerbeFilteredListe.length,
                          itemBuilder: (context, index) {
                            //final gewerbe = cloudGewerbe.gewerbeListe[index];
                            final gewerbe = searchController.text.isNotEmpty ? gewerbeSearchedListe[index]:gewerbeFilteredListe[index];
                            return GestureDetector(
                              onTap:() {Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Gewerbeseite(documentId:gewerbe.id)),
                              );
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
                                      child:gewerbe.bild != null? Image.network(
                                      'https://blog.duolingo.com/content/images/2024/12/cover_why-is-duolingo-free.png',
                                      fit: BoxFit.contain,
                                      ): const Image(image: AssetImage('Assets/IconEichwalde.png')),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: 160,
                                      child: Text(gewerbe.name)
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: SizedBox(
                            width: constraints.maxWidth*0.85,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: constraints.maxWidth*0.15,
                                  color: eichwaldeGreen,
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth*0.05,
                                  ),
                                  'Kein passendes Ergebnis zu Ihrer Suchanfrage gefunden.'
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Gewerbeseite(documentId:'oXZDRgQtFI13dAo2MMkN')),
                    );
                  },
                  child: Text('Test neue Seite'),              
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
        },
      ),
    );
  }
}


/*
FilterChip(
                  label: Text('Lebensmittel'), 
                  onSelected: (bool value) {
                    setState(() {
                      GewerbeFilter.filterLebensmittel = value;
                    });
                  },
                  selectedColor: Color.fromARGB(100, 50, 150, 50),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: eichwaldeGreen,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25)
                  ),
                  selected: GewerbeFilter.filterLebensmittel,
                  showCheckmark: false,
                ),
*/

/*
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
*/
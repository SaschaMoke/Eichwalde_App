import 'package:eichwalde_app/settings.dart';
import 'package:flutter/material.dart';

//App-Files
import 'package:eichwalde_app/Gewerbe/gewerbeseite.dart';
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/cloudgewerbe.dart';

class GewerbePage extends StatefulWidget {
  const GewerbePage({super.key});

  @override
  State<GewerbePage> createState() => _GewerbePageState();
}

class _GewerbePageState extends State<GewerbePage> {
  final Cloudgewerbe cloudGewerbe = Cloudgewerbe();

  List<GewerbeModel> gewerbeListe = [];
  List<GewerbeModel> gewerbeFilteredListe = [];
  List<GewerbeModel> gewerbeSearchedListe = [];
  TextEditingController searchController = TextEditingController();

  Set<String> filterKategorien = {};
  bool filterFavoriten = false;
  bool filterAlle = true;

  @override
  void initState() {
    ladeGewerbeDaten();
    super.initState();
  }

  Future<void> ladeGewerbeDaten() async {
    final liste = await cloudGewerbe.getDocID();
    setState(() {
      gewerbeListe = liste;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gewerbeKategorien = gewerbeListe.map((x) => x.kategorie).toSet().toList();
    gewerbeKategorien.sort((a, b) {
      final aAktiv = filterKategorien.contains(a);
      final bAktiv = filterKategorien.contains(b);

      if (aAktiv && !bAktiv) return -1;
      if (!aAktiv && bAktiv) return 1;
      return a.compareTo(b); // alphabetisch innerhalb Gruppen
    });

    gewerbeFilteredListe = gewerbeListe.where((gewerbe) {
      if (filterAlle) return true;

      final filteredKategorie = filterKategorien.contains(gewerbe.kategorie);
      final favorit = Settings.gewerbeFavoriten.contains(gewerbe.id);

      if (filterFavoriten && !favorit) return false;
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
                        WidgetState.any: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            width: 2,
                            color: eichwaldeGreen,
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
                EichwaldeGradientBar(),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.575,
                  child: LayoutBuilder(
                    builder: (context, snapshot) {                      
                      if (gewerbeListe.isEmpty) {
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

                      searchController.text.isEmpty ? gewerbeSearchedListe = gewerbeFilteredListe:null;

                      if (searchController.text.isEmpty || gewerbeSearchedListe.isNotEmpty) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 250,
                          ),
                          itemCount: searchController.text.isNotEmpty ? gewerbeSearchedListe.length:gewerbeFilteredListe.length,
                          itemBuilder: (context, index) {
                            final gewerbe = searchController.text.isNotEmpty ? gewerbeSearchedListe[index]:gewerbeFilteredListe[index];
                            return GestureDetector(
                              onTap:() {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => Gewerbeseite(documentId:gewerbe.id)),);
                              },
                              child: Card(
                                //color: Color.fromARGB(255, 150, 200, 150),
                                elevation: 3,
                                shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: eichwaldeGreen,
                                  )
                                ),
                                child: Column(children: [
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: 150,
                                    height: 120,
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'Assets/IconEichwalde.png', 
                                      image: gewerbe.bild!,
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return Image(image: eichwaldeLogo);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15,0,15,0),
                                    child: SizedBox(
                                      width: 160,
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: constraints.maxWidth*0.05,
                                        ),
                                        gewerbe.name,
                                      )
                                    ),
                                  ),
                                ]),
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
            ]
          );
        },
      ),
    );
  }
}
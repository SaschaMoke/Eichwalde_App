import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';

//Packages
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/Verkehr/vbb_api.dart';
import 'package:eichwalde_app/settings.dart';

class Verkehrspage extends StatefulWidget {
  const Verkehrspage({super.key});

  @override
  State<Verkehrspage> createState() => _VerkehrspageState();
}

class _VerkehrspageState extends State<Verkehrspage> {
  List departures = [];
  List<Remarks> remarks = [];
  String lastUpdate = '';
  Timer? timer;
  int? selectedindex;
  Stations? selectedStation = Settings.standardAbfahrt == 'eichwalde' ? Stations.eichwalde:Settings.standardAbfahrt == 'friedenstr' ? Stations.friedenstr:Stations.schmockwitz;
  bool schranke = false;
  bool schrankeWidget = false;
  String schrankeWahl = Settings.standardSchranke;
  final updateFormatTime = DateFormat('HH:mm:ss');
  final updateFormatDate = DateFormat('dd.MM.yyyy');
  bool apiStatus = true;

  int currentPickedHour = 0;
  int currentPickedMinute = 0;

  @override
  void initState() {
    super.initState();
    fetchAndUpdateData();
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) => fetchAndUpdateData());
    startUpdate();
  }

  void startUpdate() {
    Future.delayed(Duration(seconds: 2), () {
      fetchAndUpdateData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAndUpdateData() async {
    try {
      final response = await http.get(
        Uri.parse('https://v6.vbb.transport.rest/stops/${selectedStation?.stationID}/departures?linesOfStops=false&remarks=true&duration=60'),
        //Uri.parse('https://v6.vbb.transport.rest/stops/900192001/departures?bus=false&tram=false&linesOfStops=false&remarks=true&duration=60'),       //Schöneweide als Test
      );

      if (response.statusCode == 200) {
        final apiResponse = VBBApiResponse.fromJson(jsonDecode(response.body));
        setState(() {
          departures = apiResponse.departures;
          lastUpdate = '${updateFormatDate.format(apiResponse.lastUpdate)}, ${updateFormatTime.format(apiResponse.lastUpdate)}';
        });
        departures.sort((a, b) {
          String aTime = a.when; 
          if (a.when == 'Fahrt fällt aus') {
            aTime = a.plannedWhen;
          }
          String bTime = b.when; 
          if (b.when == 'Fahrt fällt aus') {
            bTime = b.plannedWhen;
          }
          return aTime.compareTo(bTime);
        });
        
        schranke = checkSchranke(schrankeWahl);

        remarks = [];
        for (var element in departures) {
          List<Remarks> departureRemarks = [];
          departureRemarks = List.from(element.remarks.map((x) => Remarks.fromJson(x)),);
          for (var remark in departureRemarks) {
            if (remark.remarkType == "warning") {
              if (!remarks.contains(remark)) {
                remarks.add(remark);
              }
            } else if (remark.remarkType == "hint" && remark.remarkContent == 'Ersatzverkehr') {
              if (!remarks.contains(Remarks(remarkContent: '',remarkType: '', remarkID: 'SEV'))) {
                remarks.add(Remarks(
                  remarkID: 'SEV',
                  remarkContent: 'Es verkehrt Schienenersatzverkehr in Eichwalde. Die Busse fahren vor dem Bahnhof in der August-Bebel-Allee ab.', 
                  remarkType: '...',
                  remarkSummary: 'Ersatzverkehr',
                ));
              }
            }
          }
        }
        apiStatus = true;
      } else {
        apiStatus = false;
        throw Exception('Failed to load data');
      }
    } catch (error) {
      //throw Exception('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var currentHour = int.parse(DateFormat('HH').format(now));
    var currentMin = int.parse(DateFormat('mm').format(now));

    Color schrankeFrame; 
    Color schrankeRed; 
    Color schrankeGelb; //animieren wenn ändert     last state variable
    if (schranke) {
      schrankeFrame = Color.fromARGB(255, 255, 0, 0);
      schrankeRed = Color.fromARGB(255, 255, 0, 0);
      schrankeGelb = Color.fromARGB(255, 50, 50, 50);
    } else {
      schrankeFrame = eichwaldeGreen;
      schrankeRed = const Color.fromARGB(255, 50, 50, 50);
      schrankeGelb = const Color.fromARGB(255, 50, 50, 50);
    }

    String schrankeName;
    if (schrankeWahl == 'Lidl') {
      schrankeName = 'Friedensstraße';
    } else {
      schrankeName = 'Waldstraße';
    }

    String schrankeTimeTillAction;
    String schrankeTextAction;
    if (schranke) {
      schrankeTimeTillAction = '$nextOpen';
      schrankeTextAction = 'Nächste Öffnung: ';
    } else {
      schrankeTimeTillAction = '$nextClose';
      schrankeTextAction = 'Nächste Schließung:';
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width*0.95,
      height: MediaQuery.of(context).size.height*0.745,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
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
                    'Schranke'
                  ),
                  SizedBox(
                    width: constraints.maxWidth*0.3,
                  ),
                  SizedBox(
                    width: constraints.maxWidth*0.125,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (schrankeWahl == 'Lidl') {
                            schrankeWahl = 'Wald';
                          } else {
                            schrankeWahl = 'Lidl';
                          }
                        });
                        schranke = checkSchranke(schrankeWahl); 
                      }, 
                      icon: const Icon(Icons.swap_horiz_rounded),
                      iconSize: constraints.maxWidth*0.08,
                      color: eichwaldeGreen,
                      tooltip: 'Wechseln Sie zwischen der Schranke Friedensstraße und Waldstraße.',
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth*0.125,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline_rounded),
                      iconSize: constraints.maxWidth*0.08,
                      color: eichwaldeGreen,
                      tooltip: 'Der Status der Schranke ist eine Berechnung aus Abfahrtszeiten. Keine Garantie für Richtigkeit.',
                    ),
                  ),
                ],
              ), 
              Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth*0.025,
                  ),
                  Text(
                    style: TextStyle(
                      height: 0.5,
                      fontSize: constraints.maxWidth*0.05,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                    'Ort: $schrankeName'
                  ),
                ],
              ),
              const SizedBox(height: 15),
              AnimatedContainer(//Schrankencontainer
                duration: const Duration(milliseconds: 500),
                height: 225,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 5,
                    color: schrankeFrame,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LayoutBuilder(
                  builder: (contextSchranke, constraints) {
                    return apiStatus ? Column(
                      children: [
                        SizedBox(
                          height: constraints.maxHeight*0.025,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth*0.038
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.59,
                              height: constraints.maxHeight*0.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [ 
                                  SizedBox(
                                    height: constraints.maxWidth*0.015,
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize: constraints.maxWidth*0.05,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    schrankeTextAction,
                                  ),
                                  SizedBox(
                                    height: constraints.maxWidth*0.005,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          style: TextStyle(
                                            fontSize: constraints.maxWidth*0.125,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          schrankeTimeTillAction
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: constraints.maxWidth*0.035,
                                          ),
                                          Text(
                                              style: TextStyle(
                                                fontSize: constraints.maxWidth*0.075,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            'min'
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.17,
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: constraints.maxWidth*0.0325
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  height: 100,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 500),
                                          height: 26,
                                          width: 26,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            color: schrankeRed,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          height: 26,
                                          width: 26,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            color: schrankeGelb,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: constraints.maxWidth,
                          height: 2,
                          color: const Color.fromARGB(255, 50, 50, 50),
                        ),
                        SizedBox(
                          height: constraints.maxHeight*0.025,
                        ),
                        SizedBox(
                          height: constraints.maxHeight*0.275,
                          width: constraints.maxWidth*0.95,
                          child: schrankeTrains.isNotEmpty ? ListView.builder(
                            itemCount: schrankeTrains.length,
                            itemBuilder: (context, index) {
                              final train = schrankeTrains[index];
                              return Text(
                                textAlign: TextAlign.center,
                                '${train.line}  ${train.destination}'
                              );
                            }):const Text(
                              textAlign: TextAlign.center,
                              'Keine Züge'
                          ),
                        ),
                      ],
                    ):Center(
                      child: const Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                        ),
                        'Es konnten keine Daten empfangen werden.'
                      ),
                    );
                  }
                )
              ),
              const SizedBox(height: 20),
              EichwaldeGradientBar(),
              //Abfahrtenbereich
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
                    'Abfahrten'
                  ),
                ],
              ),   
              Align(
                child: DropdownMenu<Stations>(
                  width: constraints.maxWidth*0.99,
                  initialSelection: selectedStation,
                  controller: TextEditingController(),
                  requestFocusOnTap: true,
                  onSelected: (Stations? val) {
                    setState(() {
                      selectedStation = val;
                    });
                    fetchAndUpdateData();
                  },
                  hintText: selectedStation?.stationName,
                  enableFilter: true,
                  keyboardType: TextInputType.none, //<=Je nach Menge an Stationen
                  dropdownMenuEntries: Stations.values.map<DropdownMenuEntry<Stations>>((Stations station) {
                    return DropdownMenuEntry<Stations>(
                      value: station,
                      label: station.stationName,
                      style: MenuItemButton.styleFrom(
                        overlayColor: eichwaldeGreen,
                      ),
                    );
                  }).toList(),
                  menuStyle: MenuStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          width: 2,
                          color: eichwaldeGreen,
                        ),
                      ),
                    ),
                    fixedSize: WidgetStatePropertyAll(Size.fromWidth(constraints.maxWidth*0.99,))
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: textFeldfocusBorder,
                    enabledBorder: textFeldfocusBorder,
                    focusedBorder: textFeldfocusBorder,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: remarks.length > 1 ? 100:remarks.length == 1 ? 70:0,
                child: ListView.builder(
                  physics: remarks.length == 1 ? NeverScrollableScrollPhysics():ScrollPhysics(), 
                  itemCount: remarks.length,
                  itemBuilder: (context, index) {
                    final remark = remarks[index];
                    final List<String> subStrings = remark.remarkContent.split('<a href="');
                    subStrings.length > 1 ? subStrings[1] = subStrings[1].replaceRange(subStrings[1].indexOf('" target='), null, ''):null; 
                    //Unsicher, ob das stabil funktioniert. Braucht eventuell nochmal überarbeitung
                    
                    return Card(
                      surfaceTintColor: remark.remarkSummary == 'Information.' ? eichwaldeGreen :
                                        remark.remarkSummary == 'Störung.' ? const Color.fromARGB(255, 255, 0, 0) :
                                        const Color.fromARGB(255, 255, 255, 0),
                      child: ListTile(
                        leading: Icon(
                          size: constraints.maxWidth*0.1,
                          remark.remarkSummary == 'Information.' ? Icons.info_outline_rounded :
                          remark.remarkSummary == 'Bauarbeiten.' || remark.remarkSummary == 'Ersatzverkehr' ? Icons.construction_rounded:
                          Icons.warning_amber_rounded,
                        ),
                        title: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: constraints.maxWidth*0.055
                          ),
                          remark.remarkSummary!.replaceAll('.', ''),
                        ),
                        subtitle: Text(
                            style: TextStyle(
                              fontSize: constraints.maxWidth*0.035,
                              height: 1,
                            ),
                            '${remark.remarkContent.substring(0,remark.remarkContent.length < 25 ? remark.remarkContent.length:25)}...'
                          ),
                        trailing: IconButton(
                          icon: Icon(
                            size: constraints.maxWidth*0.075,
                            Icons.more_horiz_rounded
                          ),
                          onPressed: () {
                            showDialog(
                              context: context, 
                              builder: (context) => AlertDialog(
                                title: SizedBox(
                                  width: constraints.maxWidth*0.75,
                                  child: Row(
                                    children: [
                                      Icon(
                                        size: constraints.maxWidth*0.135,
                                        remark.remarkSummary == 'Information.' ? Icons.info_outline_rounded :
                                        remark.remarkSummary == 'Bauarbeiten.' || remark.remarkSummary == 'Ersatzverkehr' ? Icons.construction_rounded:
                                        Icons.warning_amber_rounded,
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth*0.005,
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth*0.48,
                                        child: Text(
                                          style: TextStyle(
                                            fontSize: constraints.maxWidth*0.07,
                                            fontWeight: FontWeight.bold
                                          ),
                                          remark.remarkSummary!.replaceAll('.', ''),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(
                                          size: constraints.maxWidth*0.1,
                                          Icons.close_rounded
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                titlePadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                content: SizedBox(
                                  width: constraints.maxWidth*0.75,
                                  child: RichText(
                                    text: TextSpan(
                                      text: subStrings[0],
                                        style: TextStyle(
                                      ),
                                      children: [
                                        subStrings.length > 1 ? TextSpan(
                                          text: 'Mehr Informationen',
                                          style: TextStyle(
                                            color: eichwaldeGreen,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()..onTap = () async {
                                            final Uri url =  Uri.parse(subStrings[1]);
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode.externalApplication,
                                            );
                                          },
                                        ):TextSpan(),
                                      ]
                                    )
                                  ),
                                ),
                                surfaceTintColor: remark.remarkSummary == 'Information.' ? eichwaldeGreen :
                                                  remark.remarkSummary == 'Störung.' ? const Color.fromARGB(255, 255, 0, 0) :
                                                  const Color.fromARGB(255, 255, 255, 0),
                              )
                            );
                          },
                        ),
                      )
                    );
                  },
                ),
              ),
              if (remarks.isNotEmpty) const SizedBox(height: 5),
              SizedBox(
                height: constraints.maxHeight*0.75,//pixelwert
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
                    child: departures.isNotEmpty ? ListView.builder(
                      itemCount: departures.length,
                      itemBuilder: (context, index) {
                        final departure = departures[index];
                                
                        bool additionalInfoExists = false;
                        String shortTripDest = '';
                        List<Widget> additionalInfo = [];
                        for (var element in List.from(departure.remarks.map((x) => Remarks.fromJson(x)),)) {
                          if (element.remarkCode =='text.realtime.journey.partially.cancelled.between') {
                            additionalInfoExists = true;
                            additionalInfo.add(Text(
                              style: TextStyle(
                                fontSize: 15,
                                color: const Color.fromARGB(255, 255, 0, 0),
                                fontStyle: FontStyle.italic,
                              ),
                              'Fahrtverkürzung',
                            ));
                            shortTripDest = element.remarkContent;
                            shortTripDest = shortTripDest.substring(shortTripDest.indexOf("between")+8,shortTripDest.indexOf("and"));
                          } else if (element.remarkCode =='text.realtime.journey.additional.service') {
                            additionalInfoExists = true;
                            additionalInfo.add(Text(
                              style: TextStyle(
                                fontSize: 15,
                                color: eichwaldeGreen,
                                fontStyle: FontStyle.italic,
                              ),
                              'Zusatzfahrt',
                            ));
                          } else if (element.remarkType == 'hint' && element.remarkContent == 'Ersatzverkehr') {
                            additionalInfoExists = true;
                            additionalInfo.add(Text(
                              style: TextStyle(
                                fontSize: 15,
                                color: const Color.fromARGB(255, 255, 100, 0),
                                fontStyle: FontStyle.italic,
                              ),
                              'Ersatzverkehr',
                            ));
                          }
                        }
                                
                        var delay = (departure.delay) / 60;
                        int mincount;
                        String deptime;
                        if (int.parse(departure.formattedHour) == currentHour) {
                          mincount = (int.parse(departure.formattedMin) - currentMin);
                        } else {
                          mincount = (int.parse(departure.formattedMin) + (60 - currentMin));
                        }
                        if (mincount == 0) {
                          if (delay > 0) {
                            deptime = 'jetzt (+${delay.round()})';
                          } else {
                            deptime = 'jetzt';
                          }
                        } else {
                          if (delay > 0) {
                            deptime = 'in $mincount min (+${delay.round()})';
                          } else {
                            deptime = 'in $mincount min';
                          }
                        }
                                    
                        TextStyle deststyle;
                        if (departure.when == 'Fahrt fällt aus') {
                          deststyle = const TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 255, 0, 0),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Color.fromARGB(255, 255, 0, 0),
                          );
                          deptime = 'Fahrt fällt aus';
                        } else {
                          deststyle = const TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.none,
                          );
                        }
                                    
                        AssetImage lineImage = const AssetImage('Assets/Bus.png');
                        SizedBox linelogo;
                        if (departure.product == 'suburban') {
                          if (departure.line == 'S46') {
                            lineImage = const AssetImage('Assets/S46.png');
                          } else if (departure.line == 'S8') {
                            lineImage = const AssetImage('Assets/S8.png');
                          }
                          linelogo = SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width*0.094,
                            child: Image(image: lineImage)
                          );
                        } else {
                          linelogo = SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width*0.094,
                            child: Column(
                              children: [
                                Image(
                                  image: lineImage,
                                  height: 30,
                                  width: MediaQuery.of(context).size.width*0.07,
                                ),
                                Text(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  departure.line,
                                ),
                              ],
                            ),
                          );
                        }
                                
                        return Card(
                          elevation: 3,
                          child: ListTile(
                            leading: linelogo, 
                            title: Text(
                              style: deststyle,
                              shortTripDest.isEmpty ? departure.destination:shortTripDest,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: delay > 0 && delay < 5 ? const Color.fromARGB(255, 255, 135, 0): 
                                          delay > 5 || departure.when == 'Fahrt fällt aus' ? const Color.fromARGB(255, 255, 0, 0):null,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  deptime
                                ),
                                additionalInfoExists ? Column(
                                  children: additionalInfo,
                                ):SizedBox(), 
                              ],
                            ),                     
                            trailing: '${departure.platform}' != "null" ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  'Gleis:'
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  '${departure.platform}'
                                ),
                              ],
                            ):SizedBox(),
                            shape: Border(),
                          ),
                        );
                      },
                    ): Center(
                      child: apiStatus ? const Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                        ),
                        'Keine Abfahrten in den nächsten 60 min.'
                      ):const Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                        ),
                        'Es konnten keine Daten empfangen werden.'
                      ),
                    ),
                  ),
                )
              ),
              
              
              /*Container(//Abfahrtencontainer
                height: 400,
                decoration: BoxDecoration(
                  //color: eichwaldeGreen,
                  gradient: LinearGradient(colors: [Color.fromARGB(100, 80, 175, 50), Color.fromARGB(100, 0, 80, 160)]),
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255)
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),*/
              const SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: constraints.maxWidth*0.035,
                  fontWeight: FontWeight.w500,
                ),
                'Zuletzt aktualisiert: $lastUpdate'
              )
            ],
          );
        },
      ),
    );
  }
}

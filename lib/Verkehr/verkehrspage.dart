import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/Verkehr/vbb_api.dart';

import 'package:http/http.dart' as http;
import 'package:home_widget/home_widget.dart';

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
  Stations? selectedStation = Stations.eichwalde;
  bool schranke = false;
  bool schrankeWidget = false;
  String schrankeWahl = 'Lidl';
  final updateFormatTime = DateFormat('HH:mm:ss');
  final updateFormatDate = DateFormat('dd.MM.yyyy');

  int currentPickedHour = 0;
  int currentPickedMinute = 0;

  //Home Widget:
  String appGroupId = "group.eichwaldeApp";
  String iOSWidgetName = "EichwaldeAppHomeWidget";
  String androidWidgetName = "EichwaldeAppHomeWidget";
  String dataKey = "rom_eichwalde_app";

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId(appGroupId);
    fetchAndUpdateData();
    timer = Timer.periodic(
      const Duration(seconds: 30), (Timer t) => fetchAndUpdateData());
    selectedStation = Stations.eichwalde;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAndUpdateData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://v6.vbb.transport.rest/stops/${selectedStation?.stationID}/departures?linesOfStops=false&remarks=true&duration=60'),
        //Uri.parse('https://v6.vbb.transport.rest/stops/900192001/departures?linesOfStops=false&remarks=false&duration=60'),       Schöneweide als Test
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
        
        schranke = checkSchranke(departures, schrankeWahl);

        //Icon Attention, Layout, Dopplung entfernen
        remarks = [];
        for (var element in departures) {
          List<Remarks> departureRemarks = [];
          departureRemarks = List.from(element.remarks.map((x) => Remarks.fromJson(x)),);
          for (var remark in departureRemarks) {
            if (remark.remarkType == "warning") {
              if (!remarks.contains(remark)) {
                remarks.add(remark);
              }
            }
          }
        }

        remarks.add(Remarks(
          remarkContent: 'WALLAH KRISE', 
          remarkType: 'warning'
        ));
        remarks.add(Remarks(
          remarkContent: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 
          remarkType: 'warning'
        ));

        //Widget Stuff
        schrankeWidget = checkSchranke(departures, 'Lidl'); //<= settingSchrankeWidget      <= Design rot/grün
        //nextOpen, nextClose <= Zeit

        //save Widget
        String widgetData = schrankeWidget ? 'Öffnung: $nextOpen':'Schließung: $nextClose';
        //String widgetData = 'Hi';
        await HomeWidget.saveWidgetData(dataKey, widgetData);

        //update Widget
        await HomeWidget.updateWidget(
          iOSName: iOSWidgetName,
          androidName: androidWidgetName,
        );

      } else {
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
      schrankeFrame = Color.fromARGB(255, 0, 200, 0);
      schrankeRed = Color.fromARGB(255, 50, 50, 50);
      schrankeGelb = Color.fromARGB(255, 50, 50, 50);
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
      //schrankeTimeTillAction = 'Nächste Öffnung: $nextOpen min';
      schrankeTimeTillAction = '$nextOpen';
      schrankeTextAction = 'Nächste Öffnung: ';
    } else {
      //schrankeTimeTillAction = 'Nächste Schließung: $nextClose min';
      schrankeTimeTillAction = '$nextClose';
      schrankeTextAction = 'Nächste Schließung:';
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width*0.95,
      height: MediaQuery.of(context).size.height*0.75,
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
                          schranke = checkSchranke(departures, schrankeWahl); 
                        }, 
                        icon: Icon(Icons.swap_horiz_rounded),
                        iconSize: constraints.maxWidth*0.08,
                        color: eichwaldeGreen,
                        tooltip: 'Wechseln Sie zwischen der Schranke Friedensstraße und Waldstraße.',
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth*0.125,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.info_outline_rounded),
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
                SizedBox(
                  height: 15,
                ),
                AnimatedContainer(//Schrankencontainer
                  duration: Duration(milliseconds: 500),
                  height: 225,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: schrankeFrame,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    //color: Color.fromARGB(255, 235, 235, 235),
                  ),
                  child: LayoutBuilder(
                    builder: (contextSchranke, constraints) {
                      return departures.isNotEmpty ? Column(
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
                                        //height: constraints.maxWidth*0.0015,
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
                                        SizedBox(
                                          width: 5,
                                        ),
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
                                    padding: EdgeInsets.all(10),
                                    height: 100,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AnimatedContainer(
                                            duration: Duration(milliseconds: 500),
                                            height: 26,
                                            width: 26,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              color: schrankeRed,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
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
                            color: Color.fromARGB(255, 50, 50, 50),
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
                              }):Text(
                                textAlign: TextAlign.center,
                                'Keine Züge'
                            ),
                          ),
                        ],
                      ):Center(
                          child: Text(
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
                SizedBox(
                  height: 20,
                ),
                EichwaldeGradientBar(),
                //Abfahrtenbereich
                SizedBox(
                  height: 10,
                ),
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
                    initialSelection: Stations.eichwalde,
                    controller: TextEditingController(),
                    requestFocusOnTap: true,
                    label: Text('Haltestelle: ${selectedStation!.stationName}'),//const Text('Ausgewählte Haltestelle'),
                    onSelected: (Stations? val) {
                      setState(() {
                        selectedStation = val;
                      });
                      fetchAndUpdateData();
                    },
                    hintText: selectedStation!.stationName,
                    //helperText: 'Hello',
                    //errorText: null,
                    enableFilter: true,
                    dropdownMenuEntries: Stations.values.map<DropdownMenuEntry<Stations>>((Stations station) {
                      return DropdownMenuEntry<Stations>(
                        value: station,
                        label: station.stationName,
                        style: MenuItemButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 0, 0, 0),
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
                            color: Color.fromARGB(255, 50, 150, 50)
                          ),
                        ),
                      ),
                    ),
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      border: textFeldNormalBorder,
                      enabledBorder: textFeldNormalBorder,
                      focusedBorder: textFeldfocusBorder,
                      //filled: true,
                      //fillColor: Color.fromARGB(255, 240, 240, 230), //Farbe
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: remarks.length,
                    itemBuilder: (context, index) {
                      final remark = remarks[index];

                      return Card(
                        surfaceTintColor: Color.fromARGB(255, 255, 255, 0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: constraints.maxWidth*0.15,
                              height: 75,
                              child: Icon(
                                size: constraints.maxWidth*0.1,
                                Icons.warning_amber_rounded
                              )
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.65,
                              child: Text(
                               '${remark.remarkContent.substring(0,remark.remarkContent.length < 50 ? remark.remarkContent.length:50)}...'
                              )
                            ),
                            SizedBox(
                              width: constraints.maxWidth*0.15,
                              height: 50,
                              child: IconButton(
                                icon: Icon(
                                  size: constraints.maxWidth*0.075,
                                  Icons.more_horiz_rounded
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context, 
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(
                                            size: constraints.maxWidth*0.15,
                                            Icons.warning_amber_rounded
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize: constraints.maxWidth*0.075,
                                              fontWeight: FontWeight.bold
                                            ),
                                            'Störung'
                                          ),
                                          SizedBox(
                                            width: constraints.maxWidth*0.14,
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
                                      titlePadding: EdgeInsets.all(10),
                                      content: Text(remark.remarkContent),
                                      surfaceTintColor: Color.fromARGB(255, 255, 255, 0),
                                    )
                                  );
                                },
                              )
                            ),
                          ],
                        )
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(//Abfahrtencontainer
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 150, 200, 150),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 255, 255)
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LayoutBuilder(
                    builder: (contextDeparture, constraintsDepartures) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: constraintsDepartures.maxHeight*0.75,//pixelwert
                            child: departures.isNotEmpty ? ListView.builder(
                              itemCount: departures.length,
                              itemBuilder: (context, index) {
                                final departure = departures[index];
                      
                                Color timecolor = const Color.fromARGB(255, 0, 0, 0);
                                var delay = (departure.delay) / 60;
                                if (delay > 0 && delay < 5) {
                                  timecolor = const Color.fromARGB(255, 255, 135, 0);
                                } else if (delay > 5) {
                                  timecolor = const Color.fromARGB(255, 255, 0, 0);
                                } else {
                                  timecolor = const Color.fromARGB(255, 0, 0, 0);
                                }
                      
                                int mincount;
                                String deptime;
                                var formattedHour = int.parse(departure.formattedHour);
                                var formattedMin = int.parse(departure.formattedMin);
                                if (formattedHour == currentHour) {
                                  mincount = (formattedMin - currentMin);
                                } else {
                                  mincount = (formattedMin + (60 - currentMin));
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
                                  timecolor = const Color.fromARGB(255, 255, 0, 0);
                                } else {
                                  deststyle = const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 0, 0, 0),
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
                                      width: MediaQuery.of(contextDeparture).size.width*0.094,
                                      child: Image(image: lineImage));
                                } else {
                                  linelogo = SizedBox(
                                    height: 60,
                                    //width: 40,
                                    width: MediaQuery.of(contextDeparture).size.width*0.094,
                                    child: Column(
                                      children: [
                                        Image(
                                          image: lineImage,
                                          height: 30,
                                          //width: 30,
                                          width: MediaQuery.of(contextDeparture).size.width*0.07,
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

                                return Center(
                                  child: SizedBox(
                                    width: constraintsDepartures.maxWidth*0.95,
                                    child: Card(
                                      child: ListTile(
                                        leading: linelogo, 
                                        title: Text(
                                            style: deststyle,
                                            departure.destination),
                                        subtitle: Text(
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: timecolor,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          deptime
                                        ),                                  
                                        trailing: '${departure.platform}' != "null" ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize: 15,
                                                color:Color.fromARGB(255, 0, 0, 0),
                                              ),
                                              'Gleis:'
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize: 15,
                                                color:Color.fromARGB(255, 0, 0, 0),
                                              ),
                                              '${departure.platform}'
                                            ),
                                          ],
                                        ):SizedBox(),
                                        shape: Border(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ): Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25
                                ),
                                'Es konnten keine Daten empfangen werden.'
                              ),
                            )
                          ),
                          Text(
                            style: TextStyle(
                              fontSize: constraintsDepartures.maxWidth*0.035,
                            ),
                            'Zuletzt aktualisiert: $lastUpdate'
                          )
                        ],
                      );
                      },
                    ),
                  ),

                  /*Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            fetchAndUpdateData();
                  
                            NotificationService().showNotification(
                              title: "Nächste Abfahrten in Eichwalde:",  //dynmaisch!
                              body: 
                  '''${departures[0].line}  ${departures[0].destination}  ${departures[0].when.substring(11,16)}                    
                  ${departures[1].line}  ${departures[1].destination}  ${departures[1].when.substring(11,16)}
                  ${departures[2].line}  ${departures[2].destination}  ${departures[2].when.substring(11,16)}''',
                            );
                          }, 
                          child: const Text('Send Notification')
                        ),
                  
                    //scheduled Notification
                    //id muss fortlaufend gespeichert werden (entspricht anzahl an timern)
                    //zudem müssen die timer gespeichert bleiben
                        ElevatedButton(
                          onPressed: () {
                            fetchAndUpdateData();
                  
                            NotificationService().scheduleNotification(
                              title: "Nächste Abfahrten in Eichwalde:",  //dynmaisch!
                              body: 
                  '''${departures[0].line}  ${departures[0].destination}  ${departures[0].when.substring(11,16)}                    
                  ${departures[1].line}  ${departures[1].destination}  ${departures[1].when.substring(11,16)}
                  ${departures[2].line}  ${departures[2].destination}  ${departures[2].when.substring(11,16)}''',
                              hour: currentPickedHour,
                              minute: currentPickedMinute,
                            );
                          }, 
                          child: const Text('Schedule Notification')
                        ),
                      ],
                    ),
                    Container(
                      width: 400,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 150, 200, 150),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255)
                        ),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        children: [
                          NumberPicker(
                            infiniteLoop: true,
                            minValue: 0, 
                            maxValue: 23, 
                            value: currentPickedHour, //aktuelle Zeit?
                            onChanged: (value) => setState(() => currentPickedHour = value)
                          ),
                          NumberPicker(
                            infiniteLoop: true,
                            minValue: 0, 
                            maxValue: 59, 
                            value: currentPickedMinute, //aktuelle Zeit?
                            onChanged: (value) => setState(() => currentPickedMinute = value)
                          ),
                          ElevatedButton(
                            onPressed: () => Overlay.of(context).insert(scheduleAlarmOverlay),
                            child: const Text('Overlay test'))
                        ],
                      ),
                    ),*/
            ],
          );
        },
      ),
    );
  }
}

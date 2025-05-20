import 'package:eichwalde_app/Verkehr/vbb_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eichwalde_app/Design/eichwalde_design.dart';

class Settings {
  static String standardSchranke = '';
  static String standardAbfahrt = '';
}

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  Settings.standardSchranke = prefs.getString('schrankeStandard') ?? 'Lidl';
  Settings.standardAbfahrt = prefs.getString('abfahrtStandard') ?? 'eichwalde';
}

Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('schrankeStandard', Settings.standardSchranke);
  await prefs.setString('abfahrtStandard', Settings.standardAbfahrt);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  bool setting1 = false; //=> Einstellungsbools
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: MediaQuery.of(context).size.height*0.7,  //ist eig kaka
            width: constraints.maxWidth*0.95,
            child: ListView(
              children: [
                //Einstellungen
                Text(
                  style: TextStyle(
                    fontSize: constraints.maxWidth*0.09,
                    fontWeight: FontWeight.w500,
                  ),
                'Verkehr'
                ), 
                Text(
                  style: TextStyle(
                    height: 0.5,
                    fontSize: constraints.maxWidth*0.05,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                  'Standardauswahl Schranke'
                ),
                const SizedBox(height: 10),
                DropdownMenu(
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: 'Lidl', 
                      label: 'Friedenstraße',
                      style: MenuItemButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        overlayColor: eichwaldeGreen,
                      ),
                    ),
                    DropdownMenuEntry(
                      value: 'Wald', 
                      label: 'Waldstraße',
                      style: MenuItemButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        overlayColor: eichwaldeGreen,
                      ),
                    ),
                  ],
                  width: constraints.maxWidth*0.99,
                  initialSelection: Settings.standardSchranke == 'Lidl' ? 'Lidl':'Wald',
                  controller: TextEditingController(),
                  requestFocusOnTap: true,
                  onSelected: (String? val) {
                    setState(() {
                      Settings.standardSchranke = val!;
                    });
                    saveSettings();
                  },
                  hintText: Settings.standardSchranke == 'Lidl' ? 'Friedenstraße':'Waldstraße',
                  keyboardType: TextInputType.none,
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
                  ),
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: textFeldNormalBorder,
                    enabledBorder: textFeldNormalBorder,
                    focusedBorder: textFeldfocusBorder,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  style: TextStyle(
                    height: 0.5,
                    fontSize: constraints.maxWidth*0.05,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                  'Standardauswahl Abfahrten'
                ),
                const SizedBox(height: 10),
                DropdownMenu(
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: 'eichwalde', 
                      label: 'S Eichwalde',
                      style: MenuItemButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        overlayColor: eichwaldeGreen,
                      ),
                    ),
                    DropdownMenuEntry(
                      value: 'friedenstr', 
                      label: 'Eichwalde, Friedenstr.',
                      style: MenuItemButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        overlayColor: eichwaldeGreen,
                      ),
                    ),
                    DropdownMenuEntry(
                      value: 'schmockwitz', 
                      label: 'Eichwalde, Schmöckwitzer Str.',
                      style: MenuItemButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        overlayColor: eichwaldeGreen,
                      ),
                    ),
                  ],
                  width: constraints.maxWidth*0.99,
                  initialSelection: Settings.standardAbfahrt == 'eichwalde' ?
                                    'eichwalde':Settings.standardAbfahrt == 'friedenstr' ?
                                    'friedenstr':
                                    'schmockwitz',
                  controller: TextEditingController(),
                  requestFocusOnTap: true,
                  onSelected: (String? val) {
                    setState(() {
                      Settings.standardAbfahrt = val!;
                    });
                    saveSettings();
                  },
                  hintText: Settings.standardAbfahrt == 'eichwalde' ? 
                            Stations.eichwalde.stationName:Settings.standardAbfahrt == 'friedenstr' ? 
                            Stations.friedenstr.stationName:
                            Stations.schmockwitz.stationName,
                  keyboardType: TextInputType.none,
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
                  ),
                  textStyle: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: textFeldNormalBorder,
                    enabledBorder: textFeldNormalBorder,
                    focusedBorder: textFeldfocusBorder,
                  ),
                ),
                const SizedBox(height: 10),
                EichwaldeGradientBar(),
                //Unten
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: constraints.maxWidth*0.025
                      ),
                      'Made with '
                    ),
                    Icon(
                      color: const Color.fromARGB(255, 255, 0, 0),
                      Icons.favorite,
                      size: constraints.maxWidth*0.05,
                    ),
                    Text(
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: constraints.maxWidth*0.025
                      ),
                      ' in Eichwalde. Für Eichwalde.'
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Image(
                  //width: constraints.maxWidth*0.01,
                  height: constraints.maxWidth*0.2,
                  image: const AssetImage('Assets/IconEichwaldeneu2.png')
                ),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: constraints.maxWidth*0.02
                  ),
                  '''Alle Rechte Vorbehalten. Keine Garantie für Richtigkeit und Aktualität von Angaben.
Offiziell unterstützt durch die Gemeinde Eichwalde.'''
                ),
              ],
            ),
          );
        }
      );
  }
}

/*Text(
                  style: TextStyle(
                    fontSize: constraints.maxWidth*0.09,
                    fontWeight: FontWeight.w500,
                  ),
                'Überschrift'
                ), 
                Text(
                  style: TextStyle(
                    height: 0.5,
                    fontSize: constraints.maxWidth*0.05,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                  'Kleine Überschrift'
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: setting1, 
                  onChanged: (bool value) {
                    setState(() {
                      setting1 = value;
                    });
                  },
                  secondary: Icon(Icons.face),    //Fronticon
                  activeColor: eichwaldeGradientGreen,
                  inactiveThumbColor: eichwaldeGradientBlue,
                  //Design:
                  tileColor: Color.fromARGB(255, 255, 255, 255),
                  //title: ,
                  //subtitle: ,
                ),*/
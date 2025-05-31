import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

//Packages
import 'package:shared_preferences/shared_preferences.dart';

//App-Files
import 'package:eichwalde_app/Verkehr/vbb_api.dart';
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'package:eichwalde_app/about.dart';

class Settings {
  static String standardSchranke = '';
  static String standardAbfahrt = '';
  static bool simpleLanguage = false;

  static List<String> gewerbeFavoriten = [];
}

Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  Settings.standardSchranke = prefs.getString('schrankeStandard') ?? 'Lidl';
  Settings.standardAbfahrt = prefs.getString('abfahrtStandard') ?? 'eichwalde';
  Settings.simpleLanguage = prefs.getBool('simpleLanguage') ?? false;
  Settings.gewerbeFavoriten = prefs.getStringList('gewerbeFavoriten') ?? [];
}

Future<void> saveGewerbeFavoriten() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('gewerbeFavoriten', Settings.gewerbeFavoriten);
}

Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('schrankeStandard', Settings.standardSchranke);
  await prefs.setString('abfahrtStandard', Settings.standardAbfahrt);
  await prefs.setBool('simpleLanguage', Settings.simpleLanguage);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: MediaQuery.of(context).size.height*0.745,  //ist eig kaka
          width: constraints.maxWidth*0.95,
          child: ListView(
            children: [
              //Einstellungen
              Text(
                style: TextStyle(
                  fontSize: constraints.maxWidth*0.09,
                  fontWeight: FontWeight.w500,
                ),
              'Erscheinungsbild'
              ),
              SwitchListTile(
                title: const Text('Dunkeler Modus'),
                value: Provider.of<ThemeNotifier>(context).isDarkMode,
                onChanged: (value) {
                  Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                },
                shape: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: eichwaldeGreen,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),  
                ),
                activeColor: eichwaldeGreen,
                inactiveThumbColor:const Color.fromARGB(255, 200, 25, 0),
              ),
              const SizedBox(height: 10),
              Text(
                style: TextStyle(
                  height: 0.5,
                  fontSize: constraints.maxWidth*0.05,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
                'Barrierefreiheit'
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Einfache Sprache'),
                value: Settings.simpleLanguage,
                onChanged: (value) {
                  setState(() {
                    Settings.simpleLanguage = value;
                  });
                  saveSettings();
                },
                shape: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: eichwaldeGreen,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),  
                ),
                activeColor: eichwaldeGreen,
                inactiveThumbColor:const Color.fromARGB(255, 200, 25, 0),
              ),
              const SizedBox(height: 10),
              EichwaldeGradientBar(),
              //const SizedBox(height: 10),
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
                      overlayColor: eichwaldeGreen,
                    ),
                  ),
                  DropdownMenuEntry(
                    value: 'Wald', 
                    label: 'Waldstraße',
                    style: MenuItemButton.styleFrom(
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
                  fixedSize: WidgetStatePropertyAll(Size.fromWidth(constraints.maxWidth*0.95,))
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: textFeldfocusBorder,
                  enabledBorder: textFeldfocusBorder,
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
                      overlayColor: eichwaldeGreen,
                    ),
                  ),
                  DropdownMenuEntry(
                    value: 'friedenstr', 
                    label: 'Eichwalde, Friedenstr.',
                    style: MenuItemButton.styleFrom(
                      overlayColor: eichwaldeGreen,
                    ),
                  ),
                  DropdownMenuEntry(
                    value: 'schmockwitz', 
                    label: 'Eichwalde, Schmöckwitzer Str.',
                    style: MenuItemButton.styleFrom(
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
                  fixedSize: WidgetStatePropertyAll(Size.fromWidth(constraints.maxWidth*0.95,))
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: textFeldfocusBorder,
                  enabledBorder: textFeldfocusBorder,
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
              const SizedBox(height: 5),
              Image(
                //width: constraints.maxWidth*0.01,
                height: constraints.maxWidth*0.2,
                image: const AssetImage('Assets/IconEichwaldeneu2.png')
              ),
              const SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: constraints.maxWidth*0.02
                ),
                '''Alle Rechte Vorbehalten. Keine Garantie für Richtigkeit und Aktualität von Angaben.
Offiziell unterstützt durch die Gemeinde Eichwalde.'''
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Über die App',
                  style: TextStyle(
                    color: eichwaldeGreen,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                    fontSize: constraints.maxWidth*0.025,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => AboutPage()),);
                  },
                )
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: constraints.maxWidth*0.02
                ),
                'App-Version: 1.0'
              ),
            ],
          ),
        );
      }
    );
  }
}
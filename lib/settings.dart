import 'package:flutter/material.dart';

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
            height: MediaQuery.of(context).size.height*0.7,  //ist eig kaka
            child: ListView(
              children: [
                //Einstellungen
                SizedBox(height: 10),
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
                      color: Color.fromARGB(255, 255, 0, 0),
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
                  image: AssetImage('Assets/IconEichwaldeneu2.png')
                ),
                SizedBox(height: 5),
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
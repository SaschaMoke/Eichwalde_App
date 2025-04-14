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
        return ListView(
          children: [
            //Einstellungen
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: constraints.maxWidth*0.1
                  ),
                  'Made with '
                ),
                Icon(
                  color: Color.fromARGB(255, 255, 0, 0),
                  Icons.favorite
                ),
                Text(
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: constraints.maxWidth*0.1
                  ),
                  'in Eichwalde. Für Eichwalde.'
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: constraints.maxWidth*0.1
              ),
              'Alle Rechte Vorbehalten. Keine Garantie für Richtigkeit und Aktualität von Angaben. Offiziell unterstützt durch die Gemeinde Eichwalde.'
            ),
          ],
        );
      }
    );
  }
}
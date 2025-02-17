import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _HomepageState();
}

class _HomepageState extends State<SettingsPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 380,           //dynamisch
            child: Card(
              child: Row(
                children: [
                  Text('Text'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
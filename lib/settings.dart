import 'package:flutter/material.dart';

void removeSettingsOverlay() {
  settingsPage.remove();
  settingsPage.dispose();
}

OverlayEntry settingsPage = OverlayEntry(
  builder: (BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () => settingsPage.remove(),
        child: Text('Zurück'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60,
            width: 380,           //dynamisch
            child: Card(
              child: Text('Text'),
            )
          ),
        ],
      ),
    );
  },
);


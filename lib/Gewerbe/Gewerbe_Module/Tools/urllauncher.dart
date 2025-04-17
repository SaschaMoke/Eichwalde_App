import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

/*SnackBar linkError = SnackBar( 
  backgroundColor: Color.fromARGB(255, 50, 150, 50),
  content: Text(
  style: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: constraints.maxWidth*0.04
  ),
  'Fehler: Externe Anwendung konnte nicht gestartet werden'
  )
);*/

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorBar(BoxConstraints constraints, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color.fromARGB(255, 50, 150, 50),
        content: Text(
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: constraints.maxWidth*0.04
        ),
        'Fehler: Externe Anwendung konnte nicht gestartet werden'
        )
      )
    );
}

Future<void> launchLink(String path, String scheme, BuildContext context, BoxConstraints constraints) async {
  final Uri url =  Uri(
    scheme: scheme,
    path: path,
  );
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
   )) {
    showErrorBar(constraints, context);
  }
  
  
  /*if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color.fromARGB(255, 50, 150, 50),
        content: Text(
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: widget.constraints.maxWidth*0.04
          ),
          'Fehler: Externe Anwendung konnte nicht gestartet werden'
        )
      )
    );
  }*/
}

       
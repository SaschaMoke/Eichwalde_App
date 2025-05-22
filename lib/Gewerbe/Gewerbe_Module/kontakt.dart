import 'package:flutter/material.dart';

//Packages
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'Tools/urllauncher.dart';

class Kontakt extends StatefulWidget {
  final String adresse;
  final String telefon;
  final String mail;
  final String web;
  
  final BoxConstraints constraints;
  //... weiteres
  
  const Kontakt({
    super.key,
    this.adresse = '',
    this.telefon = '',
    this.mail = '',
    this.web = '',
    required this.constraints,
  });
  @override
  State<Kontakt> createState() => _KontaktState();
}

class _KontaktState extends State<Kontakt> {  
  @override
  Widget build(BuildContext context) { 
    List<Widget> gridTiles = List.empty(growable: true);
    if (widget.adresse.isNotEmpty) {
      gridTiles.add(SizedBox(
        width: widget.constraints.maxWidth*0.45,
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                MapsLauncher.launchQuery(widget.adresse);
              }, 
              child: Icon(
                size: widget.constraints.maxHeight*0.06,
                color: eichwaldeGreen,
                Icons.house_outlined
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
              widget.adresse
            )
          ],
        ),
      )
      );
    }

    if (widget.telefon.isNotEmpty){
      gridTiles.add(SizedBox(
        width: widget.constraints.maxWidth*0.45,
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                launchLink(
                  widget.telefon, 
                  'tel', 
                  context, 
                  widget.constraints
                );
              }, 
              child: Icon(
                size: widget.constraints.maxHeight*0.06,
                color: eichwaldeGreen,
                Icons.phone_outlined
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              widget.telefon
            )
          ],
        ),
      )
      );
    }

    if (widget.mail.isNotEmpty) {  
      gridTiles.add(SizedBox(
        width: widget.constraints.maxWidth*0.45,
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                launchLink(
                  widget.mail, 
                  'mailto', 
                  context, 
                  widget.constraints
                );
              }, 
              child: Icon(
                size: widget.constraints.maxHeight*0.06,
                color: eichwaldeGreen,
                Icons.mail_outline
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
              widget.mail
            )
          ],
        ),
      )
      );
    }

    if (widget.web.isNotEmpty) {
      gridTiles.add(SizedBox(
        width: widget.constraints.maxWidth*0.45,
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final Uri url =  Uri.parse(widget.web);
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  showErrorBar(widget.constraints, context);
                }
              }, 
              child: Icon(
                size: widget.constraints.maxHeight*0.06,
                color: eichwaldeGreen,
                Icons.web_outlined
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
              widget.web
            )
          ],
        ),
      )
      );
    }

    return ExpansionTile(
      leading: const Icon(Icons.phone_outlined), 
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Kontakt'
      ),
      shape: const Border(),
      tilePadding: const EdgeInsets.all(1),
      childrenPadding: const EdgeInsets.all(5),
      textColor: eichwaldeGreen,
      iconColor: eichwaldeGreen,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 10,
          children: gridTiles,
        )
      ],
    );
  }
}
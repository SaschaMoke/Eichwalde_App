import 'package:eichwalde_app/Design/eichwalde_design.dart';

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';

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
      gridTiles.add(Column(
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
      )
      );
    }

    if (widget.telefon.isNotEmpty){
      gridTiles.add(Column(
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
      )
      );
    }

    if (widget.mail.isNotEmpty) {  
      gridTiles.add(Column(
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
      )
      );
    }

    if (widget.web.isNotEmpty) {
      gridTiles.add(Column(
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
      )
      );
    }

    double tileRatio;
    double tileHeight;
    //!!!!!!!!!!nicht nur Adresse beachten!!!!!!
    if (widget.adresse.length > 30) {
      tileRatio = 1.25;
      tileHeight = 150;
    } else if (widget.adresse.length > 16) {
      tileRatio = 1.5;
      tileHeight = 125;
    } else {
      tileRatio = 1.75;
      tileHeight = 100;
    }

    return ExpansionTile(
      leading: Icon(Icons.phone_outlined), //ICON
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Kontakt'
      ),
      shape: const Border(),
      tilePadding: EdgeInsets.all(1),
      childrenPadding: EdgeInsets.all(5),
      textColor: eichwaldeGreen,
      iconColor: eichwaldeGreen,
      children: [
        SizedBox(
          height: (gridTiles.length ~/ 2 + gridTiles.length.remainder(2))*tileHeight,
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: tileRatio,
            children: gridTiles
          ),
        ),
      ],
    );
  }
}
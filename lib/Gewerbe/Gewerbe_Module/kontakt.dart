import 'package:flutter/material.dart';

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
              //auf Maps öffnen
            }, 
            child: Icon(
              size: widget.constraints.maxHeight*0.05,
              color: Color.fromARGB(255, 50, 150, 50),
              Icons.house_outlined
            ),
          ),
          Text(
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: widget.constraints.maxWidth*0.04
            ),
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
            onPressed: () {
              //in TelefonApp öffnen
            }, 
            child: Icon(
              size: widget.constraints.maxHeight*0.05,
              color: Color.fromARGB(255, 50, 150, 50),
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
            onPressed: () {
              //in Mail App öffnen
            }, 
            child: Icon(
              size: widget.constraints.maxHeight*0.05,
              color: Color.fromARGB(255, 50, 150, 50),
              Icons.mail_outline
            ),
          ),
          Text(
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: widget.constraints.maxWidth*0.04
            ),
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
            onPressed: () {
              //im Browser öffnen
            }, 
            child: Icon(
              size: widget.constraints.maxHeight*0.05,
              color: Color.fromARGB(255, 50, 150, 50),
              Icons.web_outlined
            ),
          ),
          Text(
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: widget.constraints.maxWidth*0.04
            ),
            widget.web
          )
        ],
      )
      );
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
      textColor: Color.fromARGB(255, 50, 150, 50),
      iconColor: Color.fromARGB(255, 50, 150, 50),   //hallooooooo
      children: [
        SizedBox(
          height: (gridTiles.length ~/ 2 + gridTiles.length.remainder(2))*100,
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.75,
            children: gridTiles
          ),
        ),
      ],
    );
  }
}
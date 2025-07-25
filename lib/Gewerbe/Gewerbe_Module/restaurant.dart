import 'package:flutter/material.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';
import 'Tools/pdf_viewer.dart';
import 'Tools/urllauncher.dart';

class Restaurant extends StatefulWidget {
  final String karte;
  final String telefon;
  final String orderLink;
  final String gewerbeName;

  final BoxConstraints constraints;
  //... weiteres
  
  const Restaurant({
    super.key,
    this.karte = '',
    this.telefon = '',
    this.orderLink = '',
    this.gewerbeName = '',
    required this.constraints,
  });
  @override
  State<Restaurant> createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {  
  @override
  Widget build(BuildContext context) { 
    List<Widget> gridTiles = List.empty(growable: true);
    if (widget.karte.isNotEmpty) {
      gridTiles.add(SizedBox(
        width: widget.constraints.maxWidth*0.45,
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => PDFViewer(
                      constraints: widget.constraints, 
                      url: widget.karte, 
                      title: widget.gewerbeName,
                    ),
                  )
                );
              }, 
              child: Icon(
                size: widget.constraints.maxHeight*0.06,
                color: eichwaldeGreen,
                Icons.food_bank_outlined
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              'Speisekarte'
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

    if (widget.orderLink.isNotEmpty) {  
      gridTiles.add(SizedBox(
        width: widget.constraints.maxWidth*0.45,
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                //widget.orderLink öffnen
              }, 
              child: Icon(
                size: widget.constraints.maxHeight*0.06,
                color: eichwaldeGreen,
                Icons.attach_money_outlined
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              'Bestellen'
            )
          ],
        ),
      )
      );
    }
    
    return ExpansionTile(
      leading: Icon(Icons.food_bank_outlined), //ICON
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Bestellen'
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
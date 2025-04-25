import 'package:flutter/material.dart';

class Bilder extends StatefulWidget {
  //final List<String> imageLinks;
  final String image1;
  final String image2;
  final String image3;
  final String image4;
  final String image5;
  final String image6;
  final String image7;
  final String image8;
  final String image9;
  final String image10;

  final BoxConstraints constraints;
  //... weiteres
  
  const Bilder({
    super.key,
    //required this.imageLinks,
    this.image1 = '',
    this.image2 = '',
    this.image3 = '',
    this.image4 = '',
    this.image5 = '',
    this.image6 = '',
    this.image7 = '',
    this.image8 = '',
    this.image9 = '',
    this.image10 = '',
    required this.constraints,
  });
  @override
  State<Bilder> createState() => _BilderState();
}

class _BilderState extends State<Bilder> {
  @override
  Widget build(BuildContext context) {
    //List<Widget> gridTiles = List.empty(growable: true);

    return ExpansionTile(
      leading: Icon(Icons.image), //ICON
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Galerie / Bilder!!!!!'
      ),
      shape: const Border(),
      tilePadding: EdgeInsets.all(1),
      childrenPadding: EdgeInsets.all(5),
      textColor: Color.fromARGB(255, 50, 150, 50),
      iconColor: Color.fromARGB(255, 50, 150, 50),   //hallooooooo
      children: [
        CarouselView.weighted(
          flexWeights: [2,5,2],
          children: [
            widget.image1.isNotEmpty ? Image.network(widget.image1):SizedBox(),
            widget.image2.isNotEmpty ? Image.network(widget.image2):SizedBox(),
            widget.image3.isNotEmpty ? Image.network(widget.image3):SizedBox(),
            widget.image4.isNotEmpty ? Image.network(widget.image4):SizedBox(),
            widget.image5.isNotEmpty ? Image.network(widget.image5):SizedBox(),
            widget.image6.isNotEmpty ? Image.network(widget.image6):SizedBox(),
            widget.image7.isNotEmpty ? Image.network(widget.image7):SizedBox(),
            widget.image8.isNotEmpty ? Image.network(widget.image8):SizedBox(),
            widget.image9.isNotEmpty ? Image.network(widget.image9):SizedBox(),
            widget.image10.isNotEmpty ? Image.network(widget.image10):SizedBox(),
          ],
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';

class Bilder extends StatefulWidget {
  final List<String> imageLinks;
  final List<String> imageCaptions;
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
    required this.imageLinks,
    required this.imageCaptions,
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
  List<Widget> images = [];
  int imgCount = 0;
//List<Widget> gridTiles = List.empty(growable: true);

  @override
  Widget build(BuildContext context) { 
    images = [];
    imgCount = 0;
    for (var img in widget.imageLinks) {
      images.add(
        Image.network(img, fit: BoxFit.fill,),
        /*Column(
          children: [
            Image.network(img),
            Text(
              style: TextStyle(
                fontSize: widget.constraints.maxWidth*0.05,
              ),
              widget.imageCaptions[imgCount]
            )
          ],
        )*/
      );
      imgCount = imgCount+1;
    }
    return ExpansionTile(
      leading: const Icon(Icons.image),
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Galerie'
      ),
      shape: const Border(),
      tilePadding: const EdgeInsets.all(1),
      childrenPadding: const EdgeInsets.all(5),
      textColor: eichwaldeGreen,
      iconColor: eichwaldeGreen,
      children: [
        SizedBox(
          height: 250,
          child: CarouselView.weighted(
            flexWeights: [1,7,1],
            itemSnapping: true,
            backgroundColor: eichwaldeGreen,
            children: images,
              /*widget.image1.isNotEmpty ? Image.network(widget.image1):SizedBox(),
              widget.image2.isNotEmpty ? Image.network(widget.image2):SizedBox(),
              widget.image3.isNotEmpty ? Image.network(widget.image3):SizedBox(),
              widget.image4.isNotEmpty ? Image.network(widget.image4):SizedBox(),
              widget.image5.isNotEmpty ? Image.network(widget.image5):SizedBox(),
              widget.image6.isNotEmpty ? Image.network(widget.image6):SizedBox(),
              widget.image7.isNotEmpty ? Image.network(widget.image7):SizedBox(),
              widget.image8.isNotEmpty ? Image.network(widget.image8):SizedBox(),
              widget.image9.isNotEmpty ? Image.network(widget.image9):SizedBox(),
              widget.image10.isNotEmpty ? Image.network(widget.image10):SizedBox(),*/
          ),
        ),
      ],
    );
  }
}
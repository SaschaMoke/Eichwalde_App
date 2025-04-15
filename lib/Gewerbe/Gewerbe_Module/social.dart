import 'package:flutter/material.dart';

class SocialMedia extends StatefulWidget {
  final String instagramLink;
  final String instagramName;
  final String facebookLink;
  final String facebookName;
  final String youtubeLink;
  final String youtubeName;

  
  final bool showInstagram;
  final bool showFacebook;
  final BoxConstraints constraints;
  //... weiteres
  
  const SocialMedia({
    super.key,
    this.instagramLink = '',
    this.instagramName = '',
    this.facebookLink = '',
    this.facebookName = '',
    this.youtubeLink = '',
    this.youtubeName = '',
    this.showInstagram = false,
    this.showFacebook = false,
    required this.constraints,
  });
  @override
  State<SocialMedia> createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  @override
  Widget build(BuildContext context) {
    List<Widget> gridTiles = List.empty(growable: true);
    
    if (widget.showFacebook) {
      gridTiles.add(
        Column(
          children: [
            TextButton(
              onPressed: () {
                    
              }, 
              child: Image(
              //height: 50,
              height: widget.constraints.maxHeight*0.07,
                image: AssetImage('Assets/Facebook_icon.png'),
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              widget.facebookName
            )
          ]
        )
      );
    }

  if (widget.showInstagram) {
      gridTiles.add(
        Column(
          children: [
            TextButton(
              onPressed: () {
                    
              }, 
              child: Image(
              //height: 50,
              height: widget.constraints.maxHeight*0.07,
                image: AssetImage('Assets/Instagram_icon.png'),
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              widget.instagramName
            )
          ]
        )
      );
    }

    if (widget.youtubeLink.isNotEmpty) {
      gridTiles.add(
        Column(
          children: [
            TextButton(
              onPressed: () {
                    
              }, 
              child: Image(
              //height: 50,
              height: widget.constraints.maxHeight*0.07,
                image: AssetImage('Assets/Youtube_icon.png'),
              ),
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              widget.youtubeName
            )
          ]
        )
      );
    }

    return ExpansionTile(
      leading: Icon(Icons.facebook_outlined), //ICON
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Soziale Medien'
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
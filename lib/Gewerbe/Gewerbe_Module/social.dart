import 'package:flutter/material.dart';

class SocialMedia extends StatefulWidget {
  final String instagramLink;
  final String instagramName;
  final String facebookLink;
  final String facebookName;
  
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.showFacebook ? Column(
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
              ],
            ):SizedBox(),
            SizedBox(width: 20),                //hier 
            widget.showInstagram ? Column(
              children: [
                TextButton(
                  onPressed: () {
                    
                  }, 
                  child:Image(
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
                  widget.facebookName
                )

              ],
            ):SizedBox(),
          ],
        ),
      ],
    );
  }
}
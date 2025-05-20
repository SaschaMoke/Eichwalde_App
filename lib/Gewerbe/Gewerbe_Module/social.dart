import 'package:eichwalde_app/Design/eichwalde_design.dart';

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class SocialMedia extends StatefulWidget {
  final String instagramLink;
  final String instagramName;
  final String facebookLink;
  final String facebookName;
  final String youtubeLink;
  final String youtubeName;

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

    required this.constraints,
  });
  @override
  State<SocialMedia> createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  @override
  Widget build(BuildContext context) {
    List<Widget> gridTiles = List.empty(growable: true);

    if (widget.facebookLink.isNotEmpty) {
      gridTiles.add(
        SizedBox(
          width: widget.constraints.maxWidth*0.45,
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  final Uri url =  Uri.parse(widget.facebookLink);
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: eichwaldeGreen,
                      content: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: widget.constraints.maxWidth*0.04
                        ),
                        'Fehler: Externe Anwendung konnte nicht gestartet werden'
                      )
                    )
                  );
                }    
                }, 
                child: Image(
                height: widget.constraints.maxHeight*0.06,
                  image: const AssetImage('Assets/Facebook_icon.png'),
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
          ),
        )
      );
    }

  if (widget.instagramLink.isNotEmpty) {
      gridTiles.add(
        SizedBox(
          width: widget.constraints.maxWidth*0.45,
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  final Uri url =  Uri.parse(widget.instagramLink);
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: eichwaldeGreen,
                      content: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: widget.constraints.maxWidth*0.04
                        ),
                        'Fehler: Externe Anwendung konnte nicht gestartet werden'
                      )
                    )
                  );
                }   
                }, 
                child: Image(
                  height: widget.constraints.maxHeight*0.06,
                  image: const AssetImage('Assets/Instagram_icon.png'),
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
          ),
        )
      );
    }

    if (widget.youtubeLink.isNotEmpty) {
      gridTiles.add(
        SizedBox(
          width: widget.constraints.maxWidth*0.45,
          child: Column(
            children: [
              TextButton(
                onPressed: () async {
                  final Uri url =  Uri.parse(widget.youtubeLink);
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: eichwaldeGreen,
                      content: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: widget.constraints.maxWidth*0.04
                        ),
                        'Fehler: Externe Anwendung konnte nicht gestartet werden'
                      )
                    )
                  );
                }   
                }, 
                child: Image(
                  height: widget.constraints.maxHeight*0.06,
                  image: const AssetImage('Assets/Youtube_icon.png'),
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
          ),
        )
      );
    }

    return ExpansionTile(
      leading: const Icon(Icons.facebook_outlined),
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Soziale Medien'
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
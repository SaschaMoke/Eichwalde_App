import 'package:flutter/material.dart';

class Oeffnungszeiten extends StatefulWidget {
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;
  final BoxConstraints constraints;
  final String leadingHint;
  final String trailingHint;
  final bool leadingImportant;
  final bool trailingImportant;
  //... weiteres
  
  const Oeffnungszeiten({
    super.key,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.constraints,
    this.leadingHint = '',
    this.trailingHint = '',
    this.leadingImportant = false,
    this.trailingImportant = false,
  });
  @override
  State<Oeffnungszeiten> createState() => _OeffnungszeitenState();
}

class _OeffnungszeitenState extends State<Oeffnungszeiten> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.timelapse_outlined), 
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Öffnungszeiten'
      ),
      shape: const Border(),
      tilePadding: EdgeInsets.all(1),
      childrenPadding: EdgeInsets.all(5),
      textColor: Color.fromARGB(255, 50, 150, 50),
      iconColor: Color.fromARGB(255, 50, 150, 50),   //hallooooooo
      children: [
        widget.leadingHint.isNotEmpty ? Text(
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: widget.constraints.maxWidth*0.04,
            color: widget.leadingImportant ? Color.fromARGB(255, 255, 0, 0):Color.fromARGB(255, 0, 0, 0),
          ),
          '''${widget.leadingHint}          
'''                                           //FORMATIERUNG NICHT ÄNDERN!
        ):SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: widget.constraints.maxWidth*0.04
              ),
              '''Montag: 
Dienstag: 
Mittwoch: 
Donnerstag: 
Freitag: 
Samstag: 
Sonntag:'''                                   //FORMATIERUNG NICHT ÄNDERN!
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: widget.constraints.maxWidth*0.04
              ),
          '''${widget.monday}
${widget.tuesday}
${widget.wednesday}
${widget.thursday}
${widget.friday}
${widget.saturday}
${widget.sunday}'''                           //FORMATIERUNG NICHT ÄNDERN!
            ),
          ],
        ),
        
        widget.trailingHint.isNotEmpty ? Text(
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: widget.constraints.maxWidth*0.04,
            color: widget.trailingImportant ? Color.fromARGB(255, 255, 0, 0):Color.fromARGB(255, 0, 0, 0),
          ),
          '''

${widget.trailingHint}'''
        ):SizedBox(),
      ],
    );
  }
}
import 'package:flutter/material.dart';

//App-Files
import 'package:eichwalde_app/Design/eichwalde_design.dart';

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
  final String leadingImportant;
  final String trailingImportant;
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
    this.leadingImportant = 'false',
    this.trailingImportant = 'false',
  });
  @override
  State<Oeffnungszeiten> createState() => _OeffnungszeitenState();
}

class _OeffnungszeitenState extends State<Oeffnungszeiten> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.timelapse_outlined), 
      title: Text(
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.constraints.maxWidth*0.075,
        ),
        'Öffnungszeiten'
      ),
      shape: const Border(),
      tilePadding: const EdgeInsets.all(1),
      childrenPadding: const EdgeInsets.all(5),
      textColor: eichwaldeGreen,
      iconColor: eichwaldeGreen,
      children: [
        widget.leadingHint.isNotEmpty ? Text(
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: widget.constraints.maxWidth*0.04,
            color: widget.leadingImportant == 'true' ? Color.fromARGB(255, 255, 0, 0):Color.fromARGB(255, 0, 0, 0),
          ),
          textAlign: TextAlign.center,
          '${widget.leadingHint}\n'
        ):SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
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
                fontWeight: FontWeight.w500,
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
            fontWeight: FontWeight.w500,
            fontSize: widget.constraints.maxWidth*0.04,
            color: widget.trailingImportant == 'true' ? Color.fromARGB(255, 255, 0, 0):Color.fromARGB(255, 0, 0, 0),
          ),
          textAlign: TextAlign.center,
          '\n${widget.trailingHint}'
        ):SizedBox(),
      ],
    );
  }
}
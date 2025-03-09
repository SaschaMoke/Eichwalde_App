import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetgewerbeTel extends StatelessWidget {
  final String documentId;

  const GetgewerbeTel({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference gewerbes = FirebaseFirestore.instance.collection('Gewerbe');

    return FutureBuilder<DocumentSnapshot>(
      future: gewerbes.doc(documentId).get(),
      builder: (context, snapshot) {
        String text = 'Lädt...'; // Standardtext beim Laden

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('tel') && data['tel'] != null && data['tel'].toString().isNotEmpty) {
              text = 'Telefon: +${data['tel'].toString()}';
            } else {
              text = 'Keine Telefonnummer verfügbar';
            }
          } else {
            text = 'Keine Telefonnummer verfügbar';
          }
        }

        return Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(232, 240, 225, 1),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
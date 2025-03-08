import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Getgewerbeimage extends StatelessWidget {
  final String documentId;
  
  const Getgewerbeimage({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {

    CollectionReference gewerbes= FirebaseFirestore.instance.collection('Gewerbe');

    return FutureBuilder<DocumentSnapshot>(
      future: gewerbes.doc(documentId).get(), 
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
          return Image.network('${data['image']}'
                    );
            
        }
        return Text(
          style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(232, 240, 225, 1)
                    ),
                  textAlign: TextAlign.center,
                    'loading...',
                
        );
      });
  }
}
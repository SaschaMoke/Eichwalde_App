import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetgewerbeAdresse extends StatelessWidget {
  final String documentId;
  
  const GetgewerbeAdresse({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {

    CollectionReference gewerbes= FirebaseFirestore.instance.collection('Gewerbe');

    return FutureBuilder<DocumentSnapshot>(
      future: gewerbes.doc(documentId).get(), 
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(232, 240, 225, 1)
                    ),
                  textAlign: TextAlign.center,
                    '${data['adresse']}',
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
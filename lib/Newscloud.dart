import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';

class Cloudnews {
  final CollectionReference newsCollection = FirebaseFirestore.instance.collection('News');

  Future addNews(String titel, String inhalt, String fotoUrl) async {
    try {
      await newsCollection.add({
        'titel': titel,
        'inhalt': inhalt,
        'foto': fotoUrl, 
        'timestamp': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  List<String> docIDs = [];

  Future getDocId() async {
    await newsCollection.get().then(
      (snapshot) => snapshot.docs.forEach((document) {
       // print(document.reference);
        docIDs.add(document.reference.id);
      }
    ),
    );

  }

   Future deleteNews(String docId) async {
    try {
      await newsCollection.doc(docId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }
}
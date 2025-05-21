import 'package:cloud_firestore/cloud_firestore.dart';

class GewerbeModel {
  final String id;
  final String name;
  final String? bild;

  GewerbeModel({required this.id, required this.name, this.bild});
}

class Cloudgewerbe {
  final CollectionReference gewerbeCollection = FirebaseFirestore.instance.collection('Gewerbe');

  List<GewerbeModel> gewerbeListe = [];

  Future addGewerbe(String name, String gewerbeart, String adresse, int tel, String image) async {
    return await gewerbeCollection.add({
      'name': name,
      'gewerbeart': gewerbeart,
      'adresse': adresse,
      'tel': tel,
      'image': image,
    });
  }

  List<String> docIDs = [];

  Future<void> getDocID() async {
    gewerbeListe.clear();
    final snapshot = await FirebaseFirestore.instance.collection('Gewerbe2').get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final data = doc.data();
      gewerbeListe.add(
        GewerbeModel(
          id: doc.id,
          name: data['name'] ?? 'Kein Name',
          bild: data['bild'],
        ),
      );
    }
  }

  Future getDocId() async {
    await gewerbeCollection.get().then(
      (snapshot) => snapshot.docs.forEach((document) {
       // print(document.reference);
        docIDs.add(document.reference.id);
      }
    ),
    );

  }

Future<void> updateGewerbe(String docId, String name, String gewerbeart, String adresse, int tel, String image) async {
  return await gewerbeCollection.doc(docId).update({
    'name': name,
    'gewerbeart': gewerbeart,
    'adresse': adresse,
    'tel': tel,
    'image': image,
  });
}


   Future<void> deleteGewerbe(String docId) async {
    try {
      await gewerbeCollection.doc(docId).delete();
    } catch (e) {
      //print('Fehler beim Löschen: $e');
      throw Exception(e);
    }
  }
}
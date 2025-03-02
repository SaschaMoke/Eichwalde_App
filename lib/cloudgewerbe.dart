import 'package:cloud_firestore/cloud_firestore.dart';

class Cloudgewerbe {
  final CollectionReference gewerbeCollection = FirebaseFirestore.instance.collection('Gewerbe');

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

  Future getDocId() async {
    await gewerbeCollection.get().then(
      (snapshot) => snapshot.docs.forEach((document) {
       // print(document.reference);
        docIDs.add(document.reference.id);
      }
    ),
    );

  }

   Future<void> deleteGewerbe(String docId) async {
    try {
      await gewerbeCollection.doc(docId).delete();
    } catch (e) {
      //print('Fehler beim Löschen: $e');
      throw e;
    }
  }
}
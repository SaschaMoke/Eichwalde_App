import 'package:cloud_firestore/cloud_firestore.dart';

class GewerbeModel {
  final String id;
  final String name;
  final String? bild;
  final String kategorie;

  GewerbeModel({required this.id, required this.name, this.bild, required this.kategorie});
}

class Cloudgewerbe {
  List<String> docIDs = [];

  Future<List<GewerbeModel>> getDocID() async {
    List<GewerbeModel> gewerbeListe = [];
    final snapshot = await FirebaseFirestore.instance.collection('Gewerbe2').get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final data = doc.data();
      gewerbeListe.add(
        GewerbeModel(
          id: doc.id,
          name: data['name'] ?? 'Kein Name',
          bild: data['bild'],
          kategorie: data['kategorie'],
        ),
      );
    }
    return gewerbeListe;
  }
}
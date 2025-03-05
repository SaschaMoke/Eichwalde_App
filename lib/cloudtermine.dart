import 'package:cloud_firestore/cloud_firestore.dart';

class CloudTermine {
  final CollectionReference termineCollection = FirebaseFirestore.instance.collection('Termine');

  Future<bool> addTermin(String name, String service, String time, DateTime date) async {
       String dateString = date.toIso8601String().split('T')[0];

      List<String> timeParts = time.split(":");
        int newHours = int.parse(timeParts[0]);
        int newMinutes = int.parse(timeParts[1]);
        int newTotalMinutes = newHours * 60 + newMinutes;
           
      QuerySnapshot existingTermine = await termineCollection
      .where('date', isEqualTo: dateString)
      .where('service', isEqualTo: service)
      .get();

     for (var doc in existingTermine.docs) {
        String existingTime = doc['time'];
        List<String> existingParts = existingTime.split(":");
        int existingHours = int.parse(existingParts[0]);
        int existingMinutes = int.parse(existingParts[1]);
        int existingTotalMinutes = existingHours * 60 + existingMinutes;

        if ((newTotalMinutes - existingTotalMinutes).abs() < 5) {
          return false; 
        }
      }

    try{
      await termineCollection.add({
      'date': dateString,
      'name': name,
      'service': service,
      'time': time,
      'timestamp': FieldValue.serverTimestamp(),
      });

    return true; // Termin erfolgreich gespeichert
    } catch (e) {
      print('Fehler beim Speichern $e');
      return false;
  }
  }


  Stream<QuerySnapshot> getTermineForDate(DateTime date) {
    return termineCollection
        .where('date', isEqualTo: date.toIso8601String().split('T')[0])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  List<String> docIDs = [];

  Future getDocId() async {
    await termineCollection.get().then(
      (snapshot) => snapshot.docs.forEach((document) {
       // print(document.reference);
        docIDs.add(document.reference.id);
      }
    ),
    );

  }

   Future<void> deleteGewerbe(String docId) async {
    try {
      await termineCollection.doc(docId).delete();
    } catch (e) {
      //print('Fehler beim Löschen: $e');
      throw e;
    }
  }
}
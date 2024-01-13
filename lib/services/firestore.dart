import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Get collections of noted from the db
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // c: add new note
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  // r: read notes
  Stream<QuerySnapshot> getNotesStream() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();

    return noteStream;
  }

  // u: update note
  Future<void> updateNote(String docId, String newNote) {
    return notes.doc(docId).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  // d: delete note
  Future<void> deleteNote(String docId) {
    return notes.doc(docId).delete();
  }
}

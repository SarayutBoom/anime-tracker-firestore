import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference animes =
      FirebaseFirestore.instance.collection('animes');

  // CREATE
  Future<void> addAnime({
    required String name,
    required int episodes,
    required int season,
    required double score,
  }) {
    return animes.add({
      'name': name,
      'episodes': episodes,
      'season': season,
      'score': score,
      'timestamp': Timestamp.now(),
    });
  }

  // READ
  Stream<QuerySnapshot> getAnimesStream() {
    return animes.orderBy('timestamp', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateAnime({
    required String docID,
    required String name,
    required int episodes,
    required int season,
    required double score,
  }) {
    return animes.doc(docID).update({
      'name': name,
      'episodes': episodes,
      'season': season,
      'score': score,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE
  Future<void> deleteAnime(String docID) {
    return animes.doc(docID).delete();
  }
}
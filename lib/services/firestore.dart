import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime.dart';

class FirestoreService {
  final CollectionReference animes =
      FirebaseFirestore.instance.collection('animes');

  // ============ CREATE ============
  Future<void> addAnime({
    required String name,
    required int episodes,
    required int watchedEpisodes,
    required int season,
    required double score,
    required AnimeStatus status,
    required bool isFavorite,
    String? imageBase64,
  }) {
    return animes.add({
      'name': name,
      'episodes': episodes,
      'watchedEpisodes': watchedEpisodes,
      'season': season,
      'score': score,
      'status': status.value,
      'isFavorite': isFavorite,
      'imageBase64': imageBase64 ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  // ============ READ ============
  Stream<QuerySnapshot> getAnimesStream() {
    return animes.orderBy('timestamp', descending: true).snapshots();
  }

  // ============ UPDATE ============
  Future<void> updateAnime({
    required String docID,
    required String name,
    required int episodes,
    required int watchedEpisodes,
    required int season,
    required double score,
    required AnimeStatus status,
    required bool isFavorite,
    String? imageBase64,
  }) {
    return animes.doc(docID).update({
      'name': name,
      'episodes': episodes,
      'watchedEpisodes': watchedEpisodes,
      'season': season,
      'score': score,
      'status': status.value,
      'isFavorite': isFavorite,
      'imageBase64': imageBase64 ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  // ============ QUICK UPDATES (ไม่ต้องอัปเดตทั้ง object) ============
  Future<void> toggleFavorite(String docID, bool isFavorite) {
    return animes.doc(docID).update({'isFavorite': isFavorite});
  }

  Future<void> updateProgress(String docID, int watchedEpisodes) {
    return animes.doc(docID).update({'watchedEpisodes': watchedEpisodes});
  }

  // ============ DELETE ============
  Future<void> deleteAnime(String docID) {
    return animes.doc(docID).delete();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // อ้างอิงถึง collection ชื่อ 'animes' บน Firestore
  final CollectionReference animes =
      FirebaseFirestore.instance.collection('animes');

  // ============ CREATE: เพิ่มอนิเมะใหม่ ============
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

  // ============ READ: ดึงข้อมูลแบบ real-time (Stream) ============
  Stream<QuerySnapshot> getAnimesStream() {
    return animes.orderBy('timestamp', descending: true).snapshots();
  }

  // ============ UPDATE: แก้ไขข้อมูล ============
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

  // ============ DELETE: ลบข้อมูล ============
  Future<void> deleteAnime(String docID) {
    return animes.doc(docID).delete();
  }
}
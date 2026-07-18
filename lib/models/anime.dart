import 'package:cloud_firestore/cloud_firestore.dart';

// สถานะการดูอนิเมะ
enum AnimeStatus {
  watching('watching', 'Watching', 'กำลังดู'),
  completed('completed', 'Completed', 'ดูจบแล้ว'),
  planToWatch('plan', 'Plan to Watch', 'วางแผนจะดู'),
  dropped('dropped', 'Dropped', 'เลิกดู');

  final String value;
  final String label;
  final String labelTh;
  const AnimeStatus(this.value, this.label, this.labelTh);

  static AnimeStatus fromValue(String? value) {
    return AnimeStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnimeStatus.watching,
    );
  }
}

// ตัวเลือกการเรียง
enum SortOption {
  latest('latest', 'Latest', 'ล่าสุด'),
  name('name', 'Name A-Z', 'ชื่อ A-Z'),
  scoreHigh('scoreHigh', 'Score: High', 'คะแนนสูงสุด'),
  episodesHigh('episodesHigh', 'Most Episodes', 'ตอนเยอะสุด');

  final String value;
  final String label;
  final String labelTh;
  const SortOption(this.value, this.label, this.labelTh);
}

// ============ Anime Model ============
class Anime {
  final String id;
  final String name;
  final int episodes;
  final int watchedEpisodes;
  final int season;
  final double score;
  final AnimeStatus status;
  final bool isFavorite;
  final String imageBase64;
  final DateTime? timestamp;

  Anime({
    required this.id,
    required this.name,
    required this.episodes,
    required this.watchedEpisodes,
    required this.season,
    required this.score,
    required this.status,
    required this.isFavorite,
    required this.imageBase64,
    this.timestamp,
  });

  // สร้างจาก Firestore document
  factory Anime.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Anime(
      id: doc.id,
      name: data['name'] ?? '',
      episodes: data['episodes'] ?? 0,
      watchedEpisodes: data['watchedEpisodes'] ?? 0,
      season: data['season'] ?? 1,
      score: (data['score'] ?? 0).toDouble(),
      status: AnimeStatus.fromValue(data['status']),
      isFavorite: data['isFavorite'] ?? false,
      imageBase64: data['imageBase64'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // % ความคืบหน้าที่ดู
  double get progressPercent {
    if (episodes == 0) return 0;
    return (watchedEpisodes / episodes).clamp(0.0, 1.0);
  }

  bool get hasImage => imageBase64.isNotEmpty;
  bool get isFullyWatched => watchedEpisodes >= episodes;
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore.dart';
import 'anime_form_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  // สีหลักของแอป
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color accentColor = Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      // -------- AppBar สวย ๆ ด้วย gradient --------
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.movie_filter_rounded, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Anime Tracker',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),

      // -------- ปุ่ม + สำหรับเพิ่มอนิเมะ --------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnimeFormScreen(),
            ),
          );
        },
        backgroundColor: accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'เพิ่มอนิเมะ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // -------- แสดงข้อมูลด้วย StreamBuilder --------
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getAnimesStream(),
        builder: (context, snapshot) {
          // กำลังโหลด
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          }

          // ไม่มีข้อมูล
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tv_off_rounded,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มีอนิเมะในลิสต์',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'กดปุ่ม + เพื่อเพิ่มอนิเมะเรื่องแรก',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // มีข้อมูล -> แสดงลิสต์
          List animeList = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = animeList[index];
              String docID = doc.id;
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              String name = data['name'] ?? '';
              int episodes = data['episodes'] ?? 0;
              int season = data['season'] ?? 0;
              double score = (data['score'] ?? 0).toDouble();

              return _buildAnimeCard(
                context: context,
                docID: docID,
                name: name,
                episodes: episodes,
                season: season,
                score: score,
                firestoreService: firestoreService,
              );
            },
          );
        },
      ),
    );
  }

  // -------- Card แสดงข้อมูลแต่ละอนิเมะ --------
  Widget _buildAnimeCard({
    required BuildContext context,
    required String docID,
    required String name,
    required int episodes,
    required int season,
    required double score,
    required FirestoreService firestoreService,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ส่วนหัวของ card - gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ส่วนเนื้อหา
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          icon: Icons.playlist_play_rounded,
                          label: 'จำนวนตอน',
                          value: '$episodes ตอน',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoTile(
                          icon: Icons.layers_rounded,
                          label: 'ซีซั่น',
                          value: 'Season $season',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Score bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 26),
                        const SizedBox(width: 8),
                        Text(
                          score.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                        const Text(
                          ' / 5.00',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        // แสดงดาวตามคะแนน
                        Row(
                          children: List.generate(5, (i) {
                            if (i < score.floor()) {
                              return const Icon(Icons.star,
                                  color: Colors.amber, size: 18);
                            } else if (i < score) {
                              return const Icon(Icons.star_half,
                                  color: Colors.amber, size: 18);
                            } else {
                              return Icon(Icons.star_border,
                                  color: Colors.grey[400], size: 18);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ปุ่มแก้ไข / ลบ
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimeFormScreen(
                                  docID: docID,
                                  initialName: name,
                                  initialEpisodes: episodes,
                                  initialSeason: season,
                                  initialScore: score,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('แก้ไข'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmDelete(
                              context, docID, name, firestoreService),
                          icon: const Icon(Icons.delete_rounded,
                              size: 18, color: Colors.white),
                          label: const Text('ลบ',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- Widget แสดงข้อมูลย่อย ๆ --------
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // -------- Dialog ยืนยันการลบ --------
  void _confirmDelete(BuildContext context, String docID, String name,
      FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('ยืนยันการลบ'),
          ],
        ),
        content: Text('ต้องการลบ "$name" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestoreService.deleteAnime(docID);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลบ "$name" เรียบร้อยแล้ว'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
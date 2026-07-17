import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore.dart';
import 'anime_form_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  // ============ DESIGN TOKENS (Light Theme) ============
  static const Color bgColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color accentColor = Color(0xFF2563EB);
  static const Color accentSoft = Color(0xFFEFF6FF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569); // เข้มขึ้นจากเดิม
  static const Color textTertiary = Color(0xFF64748B); // เข้มขึ้นจากเดิม
  static const Color errorColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: bgColor,
      // ---------- Minimal AppBar ----------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: bgColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ANIME',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tracker',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: firestoreService.getAnimesStream(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              count.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'TITLES',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ---------- FAB (แก้แล้ว - ใช้ .extended ตรง ๆ) ----------
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
        elevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'New',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ---------- Body ----------
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getAnimesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: accentColor,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'ERROR: ${snapshot.error}',
                style: const TextStyle(color: textSecondary),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          List animeList = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: animeList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              DocumentSnapshot doc = animeList[index];
              String docID = doc.id;
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return _buildAnimeCard(
                context: context,
                docID: docID,
                index: index + 1,
                name: data['name'] ?? '',
                episodes: data['episodes'] ?? 0,
                season: data['season'] ?? 0,
                score: (data['score'] ?? 0).toDouble(),
                firestoreService: firestoreService,
              );
            },
          );
        },
      ),
    );
  }

  // ---------- Empty state ----------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.movie_outlined,
              color: textTertiary,
              size: 32,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'No titles yet',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "New" to add your first anime',
            style: TextStyle(
              color: textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Anime Card ----------
  Widget _buildAnimeCard({
    required BuildContext context,
    required String docID,
    required int index,
    required String name,
    required int episodes,
    required int season,
    required double score,
    required FirestoreService firestoreService,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: textTertiary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: accentColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        score.toStringAsFixed(2),
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(left: 34),
              height: 1,
              color: borderColor,
            ),
            const SizedBox(height: 16),
            // Meta
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Row(
                children: [
                  _metaChip(label: 'EPISODES', value: episodes.toString()),
                  const SizedBox(width: 28),
                  _metaChip(label: 'SEASON', value: season.toString()),
                  const Spacer(),
                  SizedBox(
                    width: 66,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (score / 5).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${((score / 5) * 100).toInt()}%',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Actions
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Row(
                children: [
                  _actionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () {
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
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    isDanger: true,
                    onTap: () => _confirmDelete(
                        context, docID, name, firestoreService),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final Color color = isDanger ? errorColor : textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isDanger
                  ? errorColor.withValues(alpha: 0.3)
                  : borderColor,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docID, String name,
      FirestoreService firestoreService) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: errorColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete title?',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '"$name" will be permanently removed from your collection.',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: borderColor),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: errorColor,
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () async {
                          await firestoreService.deleteAnime(docID);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Deleted "$name"',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: textPrimary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
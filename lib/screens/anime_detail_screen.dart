import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime.dart';
import '../services/firestore.dart';
import 'design_tokens.dart';
import 'anime_form_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final Anime anime;

  const AnimeDetailScreen({super.key, required this.anime});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animes')
            .doc(widget.anime.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Document ถูกลบ → กลับหน้าเดิม
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.pop(context);
            });
            return const SizedBox();
          }

          final anime = Anime.fromDoc(snapshot.data!);

          return CustomScrollView(
            slivers: [
              _buildAppBar(anime),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Score
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              anime.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _bigScoreBadge(anime.score),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Status + Favorite
                      Row(
                        children: [
                          _statusBadge(anime.status),
                          const SizedBox(width: 8),
                          if (anime.isFavorite) _favoriteBadge(),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Progress section
                      _sectionLabel('01', 'PROGRESS'),
                      const SizedBox(height: 14),
                      _buildProgressSection(anime),
                      const SizedBox(height: 30),

                      // Info section
                      _sectionLabel('02', 'INFORMATION'),
                      const SizedBox(height: 14),
                      _buildInfoGrid(anime),
                      const SizedBox(height: 30),

                      // Actions
                      _sectionLabel('03', 'ACTIONS'),
                      const SizedBox(height: 14),
                      _buildActions(anime),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ========== SliverAppBar with cover ==========
  Widget _buildAppBar(Anime anime) {
    return SliverAppBar(
      expandedHeight: anime.hasImage ? 300 : 100,
      pinned: true,
      backgroundColor: AppColors.bg,
      elevation: 0,
      surfaceTintColor: AppColors.bg,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              anime.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              color: anime.isFavorite ? AppColors.favorite : Colors.white,
            ),
            onPressed: () {
              _firestoreService.toggleFavorite(anime.id, !anime.isFavorite);
            },
          ),
        ),
      ],
      flexibleSpace: anime.hasImage
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    base64Decode(anime.imageBase64),
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          AppColors.bg,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // ========== Progress Section ==========
  Widget _buildProgressSection(Anime anime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Episodes Watched',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${anime.watchedEpisodes} / ${anime.episodes}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: anime.progressPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: anime.isFullyWatched
                      ? AppColors.statusColor(AnimeStatus.completed)
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(anime.progressPercent * 100).toInt()}% complete',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Quick +/- buttons
          Row(
            children: [
              Expanded(
                child: _progressButton(
                  icon: Icons.remove_rounded,
                  onTap: anime.watchedEpisodes > 0
                      ? () => _firestoreService.updateProgress(
                          anime.id, anime.watchedEpisodes - 1)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _progressButton(
                  label: 'Mark as watched',
                  icon: Icons.check_rounded,
                  filled: true,
                  onTap: anime.watchedEpisodes < anime.episodes
                      ? () => _firestoreService.updateProgress(
                          anime.id, anime.watchedEpisodes + 1)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _progressButton(
                  icon: Icons.add_rounded,
                  onTap: anime.watchedEpisodes < anime.episodes
                      ? () => _firestoreService.updateProgress(
                          anime.id, anime.watchedEpisodes + 1)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressButton({
    String? label,
    required IconData icon,
    VoidCallback? onTap,
    bool filled = false,
  }) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: disabled
                ? AppColors.bg
                : (filled ? AppColors.accent : AppColors.bg),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: disabled
                  ? AppColors.border
                  : (filled ? AppColors.accent : AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: disabled
                    ? AppColors.textTertiary
                    : (filled ? Colors.white : AppColors.textPrimary),
              ),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: disabled
                        ? AppColors.textTertiary
                        : (filled ? Colors.white : AppColors.textPrimary),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ========== Info Grid ==========
  Widget _buildInfoGrid(Anime anime) {
    return Row(
      children: [
        Expanded(
            child: _infoCard('Episodes', anime.episodes.toString(),
                Icons.playlist_play_rounded)),
        const SizedBox(width: 10),
        Expanded(
            child: _infoCard('Season', anime.season.toString(),
                Icons.layers_rounded)),
        const SizedBox(width: 10),
        Expanded(
            child: _infoCard(
                'Score', anime.score.toStringAsFixed(2), Icons.star_rounded)),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ========== Actions ==========
  Widget _buildActions(Anime anime) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimeFormScreen(anime: anime),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.textPrimary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _confirmDelete(anime),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(Anime anime) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 22),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete title?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '"${anime.name}" will be permanently removed.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textPrimary,
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
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () async {
                          await _firestoreService.deleteAnime(anime.id);
                          if (mounted) {
                            Navigator.pop(context); // close dialog
                            Navigator.pop(context); // back to list
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

  // ========== Badges ==========
  Widget _bigScoreBadge(double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 6),
          Text(
            score.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(AnimeStatus status) {
    final color = AppColors.statusColor(status);
    final soft = AppColors.statusSoftColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.favorite.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.favorite.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.favorite, size: 14),
          SizedBox(width: 5),
          Text(
            'Favorite',
            style: TextStyle(
              color: AppColors.favorite,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String number, String label) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }
}
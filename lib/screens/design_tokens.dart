import 'package:flutter/material.dart';
import '../models/anime.dart';

class AppColors {
  static const Color bg = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color accent = Color(0xFF2563EB);
  static const Color accentSoft = Color(0xFFEFF6FF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);
  static const Color favorite = Color(0xFFEC4899);

  // สีสำหรับแต่ละ status
  static Color statusColor(AnimeStatus status) {
    switch (status) {
      case AnimeStatus.watching:
        return const Color(0xFF10B981); // green
      case AnimeStatus.completed:
        return const Color(0xFF2563EB); // blue
      case AnimeStatus.planToWatch:
        return const Color(0xFFF59E0B); // amber
      case AnimeStatus.dropped:
        return const Color(0xFF6B7280); // gray
    }
  }

  static Color statusSoftColor(AnimeStatus status) {
    switch (status) {
      case AnimeStatus.watching:
        return const Color(0xFFECFDF5);
      case AnimeStatus.completed:
        return const Color(0xFFEFF6FF);
      case AnimeStatus.planToWatch:
        return const Color(0xFFFEF3C7);
      case AnimeStatus.dropped:
        return const Color(0xFFF3F4F6);
    }
  }
}
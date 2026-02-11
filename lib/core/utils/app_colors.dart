import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF23A3A6);
  static const Color primaryDark = Color(0xFF0B3C5C);
  static const Color primaryDarker = Color(0xFF0A324A);
  
  // Couleurs de fond
  static const Color background = Color(0xFF0B3C5C);
  static const Color backgroundLight = Color(0xFFF5F6FA);
  static const Color white = Colors.white;
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF0F1A14);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDark = Color(0xFF212121);
  static const Color textGray = Color(0xFF4F4F4F);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textBlack = Color(0xFF111827);
  static const Color textDarkGray = Color(0xFF1F2937);
  static const Color textMediumGray = Color(0xFF333333);
  static const Color textLightGray = Color(0xFF6F8A99);
  
  // Couleurs de statut
  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusInProgress = Color(0xFF3B83F6);
  static const Color statusValidated = Color(0xFF23A3A6);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusDraft = Color(0xFF6B7280);
  
  // Couleurs de bordure
  static const Color border = Color(0xFFE8EEE7);
  static const Color borderLight = Color(0xFFDEE8EE);
  static const Color borderGray = Color(0xFFCBD5E1);
  static const Color borderDivider = Color(0xFFE5E7EB);
  
  // Couleurs avec opacité
  static Color whiteOpacity(double opacity) => Colors.white.withValues(alpha: opacity);
  static const Color whiteOverlay = Color(0x14FFFFFF);
  static const Color whiteOverlayLight = Color(0x1AFFFFFF);
  static const Color searchBackground = Color(0x1AF8FBF9);
  static const Color borderOverlay = Color(0x1AE8EEE7);
  static const Color primaryLight = Color(0x1423A3A6);
  static const Color primaryOverlay = Color(0x0F23A3A6);
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowDark = Color(0x08000000);
  static const Color textOverlay = Color(0x80030319);
  
  // Couleurs de statut avec opacité
  static const Color statusPendingLight = Color(0x1AF39C12);
  static const Color statusInProgressLight = Color(0x0F3B83F6);
  static const Color statusValidatedLight = Color(0x1A23A3A6);
  static const Color statusRejectedLight = Color(0x0FEF4444);
  static const Color statusDraftLight = Color(0xFFF2F5F9);
  
  // Couleurs supplémentaires
  static const Color gray = Color(0xFFF3F4F6);
  static const Color grayLight = Color(0xFFF0F0F0);
  static const Color progressBar = Color(0xFFDEE8EE);
  static const Color cardBackground = Color(0xFFF5F6FA);
}

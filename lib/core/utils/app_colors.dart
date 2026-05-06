import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFFF39C12);
  static const Color primaryDark = Color(0xFF8E342C);
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
  static Color whiteOpacity(double opacity) =>
      Colors.white.withValues(alpha: opacity);
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

  // Couleurs spécifiques
  static const Color divider = Color(0xFFD9D9D9);
  static const Color hintText = Color(0xFF9C9AA5);
  static const Color hintPassword = Color(0xFFC4C4C4);
  static const Color iconGray = Color(0xFF9CA3AF);
  static const Color backgroundModal = Color(0xFF424242);
  static const Color backgroundDarker = Color(0xFF0A324A);
  static const Color cardText = Color(0xFF222222);
  static const Color cardSubtext = Color(0xFF343A40);
  static const Color profileText = Color(0xFF374151);
  static const Color modalHandle = Color(0x80212121);
  static const Color languageBorder = Color(0xFFE5E7EB);
  static const Color languageSelected = Color(0xFFF0FDFA);
  static const Color languageBorderUnselected = Color(0xFFD1D5DB);
  static const Color borderE5 = Color(0xFFE5E5E5);

  // Couleurs barre de progression profil
  static const Color progressFill = Color(0xFFCC1C1C);
  static const Color progressTrack = Color(0xFFE0E0E0);

  // Couleurs texte supplémentaires
  static const Color textPureBlack = Color(0xFF000000);
  static const Color textBlack87 = Color(0xDD000000);
  static const Color textBlack54 = Color(0x8A000000);
  static const Color textBlack45 = Color(0x73000000);

  // Couleurs grises UI
  static const Color greyShade100 = Color(0xFFF5F5F5);
  static const Color greyShade200 = Color(0xFFEEEEEE);
  static const Color greyShade500 = Color(0xFF9E9E9E);

  // Couleurs statut spécifiques (pour les cards stats)
  static const Color statusEnAttente = Color(0xFFE6A817);
  static const Color statusEnAttenteLight = Color(0x1AE6A817);
  static const Color statusValideGreen = Color(0xFF00B388);
  static const Color statusValideGreenLight = Color(0x1A00B388);

  // Couleur bouton CTA overlay
  static const Color ctaButtonOverlay = Color(0x26FFFFFF);

  // Fond zone upload / card document
  static const Color documentCardBackground = Color(0xFFE8F0FE);

  // Bouton retour (login / inscription)
  static const Color backArrowColor = Color(0xFF97392D);
  static const Color backCircleColor = Color(0x4DA7482F);

  // OTP cases
  static const Color otpEmptyFill = Color(0x4DE0C4C0);
  static const Color otpActiveFill = Color(0x4D963A2D);
  static const Color otpActiveBorder = Color(0xFF963A2D);
  static const Color otpResendTimer = Color(0xFF963A2D);

  // Stats cards home
  static const Color statTotalBg = Color(0xFFFCFDFF);
  static const Color statTotalBorder = Color(0x806B7280);
  static const Color statTotalIconBg = Color(0xCCF0F0F0);
  static const Color statTotalIconColor = Color(0xFF0B3C5C);

  static const Color statInProgressBg = Color(0xFFF8FBFF);
  static const Color statInProgressBorder = Color(0xFF3B83F6);
  static const Color statInProgressIconBg = Color(0x1A3B83F6);
  static const Color statInProgressIconColor = Color(0xFF3B83F6);

  static const Color statPendingBg = Color(0xFFFFFCF5);
  static const Color statPendingBorder = Color(0xFFF39C12);
  static const Color statPendingIconBg = Color(0x1AF39C12);
  static const Color statPendingIconColor = Color(0xFFF39C12);

  static const Color statValidatedBg = Color(0xFFF7FFFE);
  static const Color statValidatedBorder = Color(0xFF23A3A6);
  static const Color statValidatedIconBg = Color(0x1A23A3A6);
  static const Color statValidatedIconColor = Color(0xFF23A3A6);

  // Profile completion page
  static const Color statusInProgressCircle = Color(0xFF006FFD);
  static const Color docCardEmptyBg = Color(0x4DE0C4C0);
  static const Color docCardAddIconColor = Color(0x4D97392D);

  // Document upload modal
  static const Color docUploadBorder = Color(0xFFD4B3B0);
  static const Color docUploadBg = Color(0xFFEEE7E8);
  static const Color docUploadIconBg = Color(0xFFD4B3B0);
  static const Color docUploadClickText = Color(0xFF343A40);

  // Banque - icône compte
  static const Color banqueIconBg = Color(0x1A90362E);

  // Ajout compte bancaire modal
  static const Color banqueFieldBg = Color(0xFFFBF7F7);
  static const Color banqueFieldBorder = Color(0xFF97392D);
  static const Color banqueLockIcon = Color(0xFF90362E);
  static const Color compteVerifyBg = Color(0xFF10B981);

  // Abonnements / Plans
  static const Color planTitleColor = Color(0xFF1C1B1B);
  static const Color planCardSelectedShadow = Color(0x1F97392D);
  static const Color planCheckGreen = Color(0xFF22C55E);

  // Paiement modal
  static const Color paymentModalHandle = Color(0xFFE5E2E1);
  static const Color paymentCardBg = Color(0x0D97392D);
  static const Color paymentCardBorder = Color(0xFF97392D);
  static const Color paymentIconBg = Color(0xFF97392D);
  static const Color paymentInfoBg = Color(0x1AF39C12);
  static const Color paymentInfoText = Color(0xFF333333);
  static const Color paymentBillingText = Color(0x80000000);
  static const Color paymentMethodSelectedBg = Color(0x0D97392D);
  static const Color paymentMethodUnselectedBorder = Color(0x4D6B7280);
  static const Color paymentMethodUnselectedCircle = Color(0xFFE2BFB0);
  static const Color paymentSecureText = Color(0xFF6B7280);
}

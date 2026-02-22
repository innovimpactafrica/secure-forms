import 'package:flutter/material.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

class SecurityVerificationScreen extends StatefulWidget {
  const SecurityVerificationScreen({super.key});

  @override
  State<SecurityVerificationScreen> createState() => _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState extends State<SecurityVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(AppConstants.paddingXLarge),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: AppConstants.progressStepSize,
                      height: AppConstants.progressStepSize,
                      decoration: BoxDecoration(
                        color: AppColors.whiteOverlay,
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Icon(Icons.arrow_back, color: AppColors.white, size: AppConstants.iconSizeMedium),
                    ),
                  ),
                  SizedBox(width: AppConstants.paddingLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ouverture de compte',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeXLarge,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.statusDraftLight,
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              ),
                              child: Text(
                                'Brouillon',
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeRegular,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.statusDraft,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Banque Nationale • 18/12/2025',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeMedium,
                            color: Color(0xFFB0BEC5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXLarge),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: AppConstants.progressBarHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: AppConstants.progressBarHeight,
                      decoration: BoxDecoration(
                        color: AppColors.progressBar,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    '3/5',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLightGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.paddingXLarge)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingXLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vérification de sécurité',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeTitle,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingLarge),
                      Text(
                        'Nous avons envoyé un code à 4 chiffres se terminant par **88 à votre appareil mobile pour sceller ce document.',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // OTP Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return Container(
                            width: AppConstants.otpBoxSize,
                            height: AppConstants.otpBoxSize,
                            decoration: BoxDecoration(
                              color: AppColors.gray,
                              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            ),
                            child: TextField(
                              controller: _otpControllers[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeTitle,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'Vous n\'avez pas reçu de code ?',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeLarge,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
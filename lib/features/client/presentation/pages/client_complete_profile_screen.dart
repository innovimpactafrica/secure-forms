import 'package:flutter/material.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

/// Page ouverte au clic sur "Commencer maintenant"
/// Permet au client de compléter son profil
/// TODO: connecter au ClientBloc lors de l'intégration API
class ClientCompleteProfileScreen extends StatelessWidget {
  const ClientCompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 15,
              color: Colors.black87,
            ),
          ),
        ),
        title: const Text(
          'Compléter mon profil',
          style: TextStyle(
            fontFamily: AppConstants.fontFamilySofiaSans,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression du profil',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Text(
                  '30%',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilyInter,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.30,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Section title
            const Text(
              'Informations personnelles',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const _ProfileField(label: 'Prénom', hint: 'Votre prénom'),
            const SizedBox(height: 14),
            const _ProfileField(label: 'Nom', hint: 'Votre nom de famille'),
            const SizedBox(height: 14),
            const _ProfileField(label: 'Téléphone', hint: '+221 xx xxx xx xx'),
            const SizedBox(height: 14),
            const _ProfileField(label: 'Adresse', hint: 'Votre adresse complète'),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: dispatch SaveProfileEvent via BLoC
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamilySofiaSans,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String hint;

  const _ProfileField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppConstants.fontFamilyInter,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
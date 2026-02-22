import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:secure_link/core/utils/app_colors.dart';
import 'package:secure_link/core/utils/app_constants.dart';

/// Page ouverte au clic sur une card de demande récente
/// Affiche le détail complet d'une demande
/// TODO: recevoir le modèle DemandeModel en paramètre lors de l'intégration API
class ClientDemandeDetailScreen extends StatelessWidget {
  const ClientDemandeDetailScreen({super.key});

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
          'Détail de la demande',
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
            // Demande summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ouverture de compte',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilySofiaSans,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Banque Nationale',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamilyInter,
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.statusPendingLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'En attente',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamilyInter,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.statusPending,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Info section
            const Text(
              'Informations',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            const _DetailRow(label: 'Référence', value: '#DM-2025-001'),
            const _DetailRow(label: 'Date de soumission', value: '18/12/2025'),
            const _DetailRow(label: 'Institution', value: 'Banque Nationale'),
            const _DetailRow(label: 'Type', value: 'Ouverture de compte'),
            const _DetailRow(label: 'Statut', value: 'En attente de validation'),
            const SizedBox(height: 24),
            // Documents section
            const Text(
              'Documents soumis',
              style: TextStyle(
                fontFamily: AppConstants.fontFamilySofiaSans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            const _DocumentItem(label: "Pièce d'identité", submitted: true),
            const SizedBox(height: 10),
            const _DocumentItem(
                label: 'Justificatif de domicile', submitted: true),
            const SizedBox(height: 10),
            const _DocumentItem(label: 'Formulaire bancaire', submitted: false),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: 13,
              color: Colors.black45,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppConstants.fontFamilyInter,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String label;
  final bool submitted;

  const _DocumentItem({required this.label, required this.submitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 20,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppConstants.fontFamilyInter,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            submitted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: submitted
                ? const Color(0xFF00B388)
                : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
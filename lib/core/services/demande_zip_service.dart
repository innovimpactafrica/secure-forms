import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/demande_model.dart';
import 'package:secure_link/features/client/data/repositories/demandes_repository.dart';

class DemandeZipService {
  /// Génère un ZIP contenant :
  /// - 00_resume.pdf  : page A4 avec toutes les infos texte
  /// - Les PDFs/images joints (submittedForms + requiredDocuments)
  static Future<File> genererEtZipper({
    required DemandeModel demande,
    void Function(double progress, String step)? onProgress,
  }) async {
    final token = UserSession.instance.accessToken;
    final dir = await getTemporaryDirectory();
    final dossier = Directory('${dir.path}/demande_${demande.id}');
    if (await dossier.exists()) await dossier.delete(recursive: true);
    await dossier.create();

    onProgress?.call(0.05, 'Préparation...');

    // ── 1. Résumé PDF ──
    await _genererResumePDF(demande, dossier);
    onProgress?.call(0.2, 'Résumé généré');

    // ── 2. Collecter tous les fichiers à télécharger ──
    final fichiers = <_FichierATelechager>[];

    for (int i = 0; i < demande.submittedForms.length; i++) {
      final f = demande.submittedForms[i];
      if (f.pdfUrl.isNotEmpty) {
        final nom = f.label.isNotEmpty
            ? '${_sanitize(f.label)}.pdf'
            : 'document_${i + 1}.pdf';
        fichiers.add(_FichierATelechager(nom: nom, url: f.pdfUrl, useToken: false));
      }
    }

    for (int i = 0; i < demande.requiredDocuments.length; i++) {
      final d = demande.requiredDocuments[i];
      if (d.id.isNotEmpty) {
        final nom = d.label.isNotEmpty
            ? '${_sanitize(d.label)}.pdf'
            : 'piece_${i + 1}.pdf';
        final url = (d.fileUrl != null && d.fileUrl!.isNotEmpty)
            ? d.fileUrl!
            : BaseUrl.profileDocumentFile(d.id);
        final useToken = !(url.contains('X-Amz-'));
        fichiers.add(_FichierATelechager(nom: nom, url: url, useToken: useToken));
      }
    }

    // ── 3. Télécharger en parallèle ──
    final total = fichiers.length;
    int done = 0;

    await Future.wait(fichiers.map((f) async {
      try {
        final bytes = await _telecharger(f, token);
        if (bytes != null) {
          // Éviter les doublons de noms
          var nom = f.nom;
          var dest = File('${dossier.path}/$nom');
          int suffix = 1;
          while (await dest.exists()) {
            final ext = nom.contains('.') ? '.${nom.split('.').last}' : '';
            final base = nom.contains('.') ? nom.substring(0, nom.lastIndexOf('.')) : nom;
            nom = '${base}_$suffix$ext';
            dest = File('${dossier.path}/$nom');
            suffix++;
          }
          await dest.writeAsBytes(bytes);
        }
      } catch (_) {}
      done++;
      onProgress?.call(0.2 + (done / total) * 0.6, 'Fichier $done/$total');
    }));

    onProgress?.call(0.85, 'Création du ZIP...');

    // ── 4. Créer le ZIP ──
    final shortId = demande.id.length >= 8 ? demande.id.substring(0, 8) : demande.id;
    final zipPath = '${dir.path}/demande_$shortId.zip';
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    await for (final f in dossier.list()) {
      if (f is File) encoder.addFile(f);
    }
    encoder.close();

    onProgress?.call(1.0, 'Terminé');
    return File(zipPath);
  }

  // ── Télécharge un fichier avec fallback proxy stable ──
  static Future<List<int>?> _telecharger(_FichierATelechager f, String token) async {
    // Toujours envoyer le token — les URLs MinIO signées fonctionnent sans token
    // mais si elles sont expirées on a besoin du token pour le proxy
    final headers = {'Authorization': 'Bearer $token'};

    // 1. URL directe
    try {
      final reqHeaders = f.useToken ? headers : <String, String>{};
      final res = await http.get(Uri.parse(f.url), headers: reqHeaders)
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return res.bodyBytes;
      // Si 403 sur URL MinIO → essayer avec token
      if (res.statusCode == 403 && !f.useToken) {
        final res2 = await http.get(Uri.parse(f.url), headers: headers)
            .timeout(const Duration(seconds: 30));
        if (res2.statusCode == 200) return res2.bodyBytes;
      }
    } catch (_) {}

    // 2. Proxy stable /api/storage/files/{key}
    if (f.url.contains('X-Amz-') || f.url.contains('minio') || f.url.contains('storage')) {
      try {
        final parts = Uri.parse(f.url).path.split('/');
        if (parts.length >= 3) {
          final objectKey = parts.sublist(2).join('/');
          final proxyUrl = BaseUrl.storageFile(objectKey);
          final res = await http.get(Uri.parse(proxyUrl), headers: headers)
              .timeout(const Duration(seconds: 30));
          if (res.statusCode == 200) return res.bodyBytes;
        }
      } catch (_) {}
    }

    // 3. Dernier recours : avec token sur l'URL originale
    try {
      final res = await http.get(Uri.parse(f.url), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return res.bodyBytes;
    } catch (_) {}

    return null;
  }

  // ── Génère le résumé PDF A4 ──
  static Future<void> _genererResumePDF(DemandeModel demande, Directory dossier) async {
    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('#0B3C5C');
    final accentColor = PdfColor.fromHex('#23A3A6');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // En-tête
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    demande.formType.isNotEmpty ? demande.formType : demande.requestNumber,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  if (demande.organisationName.isNotEmpty)
                    pw.Text(
                      demande.organisationName,
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 13),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Statut badge
            pw.Row(children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: accentColor,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  _labelStatut(demande.status),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ]),
            pw.SizedBox(height: 20),

            // Informations
            pw.Text('Informations',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(children: [
                _ligne('Référence', demande.requestNumber),
                _ligne('Statut', _labelStatut(demande.status)),
                if (demande.organisationName.isNotEmpty)
                  _ligne('Organisation', demande.organisationName),
                _ligne('Date soumission', demande.createdAt),
                if (demande.inProgressAt != null)
                  _ligne('En cours depuis', demande.inProgressAt!),
                if (demande.finalizedAt != null)
                  _ligne('Finalisé le', demande.finalizedAt!),
              ]),
            ),
            pw.SizedBox(height: 20),

            // Fichiers joints
            if (demande.submittedForms.isNotEmpty || demande.requiredDocuments.isNotEmpty) ...[
              pw.Text('Fichiers inclus dans ce dossier',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(children: [
                  ...demande.submittedForms
                      .where((f) => f.pdfUrl.isNotEmpty)
                      .map((f) => _ligneFichier(f.label.isNotEmpty ? f.label : 'Document')),
                  ...demande.requiredDocuments
                      .where((d) => d.id.isNotEmpty)
                      .map((d) => _ligneFichier(d.label.isNotEmpty ? d.label : 'Pièce jointe')),
                ]),
              ),
            ],

            pw.Spacer(),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 4),
            pw.Text(
              'Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} — Secure Forms',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );

    final file = File('${dossier.path}/00_resume.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  static pw.Widget _ligne(String label, String valeur) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(children: [
      pw.SizedBox(
        width: 140,
        child: pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11)),
      ),
      pw.Expanded(
        child: pw.Text(valeur,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      ),
    ]),
  );

  static pw.Widget _ligneFichier(String nom) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(children: [
      pw.Container(
        width: 20,
        height: 16,
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#23A3A6'),
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Center(
          child: pw.Text('PDF',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.Text(nom,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      ),
    ]),
  );

  static String _labelStatut(String status) {
    switch (status.toUpperCase()) {
      case 'EN_COURS': return 'En cours';
      case 'VALIDEE':
      case 'VALIDE': return 'Validée';
      case 'REJETEE':
      case 'REJETE': return 'Rejetée';
      case 'BROUILLON': return 'Brouillon';
      default: return 'En attente';
    }
  }

  static String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();

  /// Récupère les données fraîches de la demande si nécessaire
  static Future<DemandeModel> freshDemande(DemandeModel demande) async {
    if (demande.submittedForms.isNotEmpty || demande.requiredDocuments.isNotEmpty) {
      return demande;
    }
    return DemandesRepository().getRequestById(
      accessToken: UserSession.instance.accessToken,
      id: demande.id,
    );
  }
}

class _FichierATelechager {
  final String nom;
  final String url;
  final bool useToken;
  const _FichierATelechager({required this.nom, required this.url, required this.useToken});
}

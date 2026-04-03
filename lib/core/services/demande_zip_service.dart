import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:secure_link/core/utils/base_url.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/models/demande_model.dart';
import 'package:secure_link/features/client/data/repositories/demandes_repository.dart';

class DemandeZipService {
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

    // 1. Résumé PDF
    await _genererResumePDF(demande, dossier);
    onProgress?.call(0.2, 'Résumé généré');

    // 2. Collecter fichiers
    final fichiers = <_Fichier>[];

    for (int i = 0; i < demande.submittedForms.length; i++) {
      final f = demande.submittedForms[i];
      if (f.pdfUrl.isNotEmpty) {
        final nom = f.label.isNotEmpty
            ? '${_sanitize(f.label)}.pdf'
            : 'document_${i + 1}.pdf';
        fichiers.add(_Fichier(nom: nom, url: f.pdfUrl, useToken: false));
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
        fichiers.add(_Fichier(nom: nom, url: url, useToken: !url.contains('X-Amz-')));
      }
    }

    // 3. Télécharger en parallèle
    final total = fichiers.length;
    int done = 0;

    await Future.wait(fichiers.map((f) async {
      try {
        final bytes = await _telecharger(f, token);
        if (bytes != null) {
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

    // 4. ZIP
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

  // ── Téléchargement avec 3 niveaux de fallback ──
  static Future<List<int>?> _telecharger(_Fichier f, String token) async {
    final authHeaders = {'Authorization': 'Bearer $token'};

    // 1. URL directe sans token (MinIO signé)
    if (!f.useToken) {
      try {
        final res = await http.get(Uri.parse(f.url))
            .timeout(const Duration(seconds: 30));
        if (res.statusCode == 200) return res.bodyBytes;
      } catch (_) {}
    }

    // 2. URL directe avec token
    try {
      final res = await http.get(Uri.parse(f.url), headers: authHeaders)
          .timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) return res.bodyBytes;
    } catch (_) {}

    // 3. Proxy stable /api/storage/files/{key}
    try {
      final parts = Uri.parse(f.url).path.split('/');
      if (parts.length >= 3) {
        final objectKey = parts.sublist(2).join('/');
        final proxyUrl = BaseUrl.storageFile(objectKey);
        final res = await http.get(Uri.parse(proxyUrl), headers: authHeaders)
            .timeout(const Duration(seconds: 30));
        if (res.statusCode == 200) return res.bodyBytes;
      }
    } catch (_) {}

    return null;
  }

  // ── Résumé PDF A4 professionnel ──
  static Future<void> _genererResumePDF(DemandeModel demande, Directory dossier) async {
    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('#0B3C5C');
    final accentColor  = PdfColor.fromHex('#23A3A6');
    final bgLight      = PdfColor.fromHex('#F5F6FA');
    final borderColor  = PdfColor.fromHex('#DEE8EE');

    // Charger le logo
    pw.ImageProvider? logo;
    try {
      final data = await rootBundle.load('assets/images/SLLOGO.png');
      logo = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {}

    final statut = _labelStatut(demande.status);
    final titre  = demande.formType.isNotEmpty ? demande.formType : demande.requestNumber;
    final org    = demande.organisationName;
    final now    = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [

            // ── EN-TÊTE ──────────────────────────────────────────────
            pw.Container(
              color: primaryColor,
              padding: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [

                  // Logo + nom app
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      if (logo != null) ...[
                        pw.Image(logo, width: 40, height: 40),
                        pw.SizedBox(width: 12),
                      ],
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text('SECURE ',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text('FORMS',
                                style: pw.TextStyle(
                                  color: accentColor,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          pw.Text(
                            'La transmission sécurisée de confiance',
                            style: pw.TextStyle(
                              color: PdfColors.grey400,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 28),
                  pw.Container(height: 1, color: PdfColor.fromHex('#1E5070')),
                  pw.SizedBox(height: 28),

                  // Titre centré
                  pw.Text(
                    titre,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  if (org.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      org,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  pw.SizedBox(height: 20),

                  // Badge statut centré
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                      decoration: pw.BoxDecoration(
                        color: accentColor,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Text(
                        statut.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── CORPS ────────────────────────────────────────────────
            pw.Expanded(
              child: pw.Container(
                color: bgLight,
                padding: const pw.EdgeInsets.fromLTRB(40, 32, 40, 0),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // Section Informations
                    _sectionTitle('Informations de la demande', primaryColor, accentColor),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: borderColor),
                      ),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: pw.Column(children: [
                        _ligneInfo('Référence',      demande.requestNumber, primaryColor),
                        _divider(borderColor),
                        _ligneInfo('Statut',         statut, accentColor),
                        if (org.isNotEmpty) ...[
                          _divider(borderColor),
                          _ligneInfo('Organisation', org, primaryColor),
                        ],
                        _divider(borderColor),
                        _ligneInfo('Date soumission', demande.createdAt, primaryColor),
                        if (demande.inProgressAt != null) ...[
                          _divider(borderColor),
                          _ligneInfo('En cours depuis', demande.inProgressAt!, primaryColor),
                        ],
                        if (demande.finalizedAt != null) ...[
                          _divider(borderColor),
                          _ligneInfo('Finalisé le', demande.finalizedAt!, primaryColor),
                        ],
                      ]),
                    ),

                    // Section Fichiers
                    if (demande.submittedForms.isNotEmpty || demande.requiredDocuments.isNotEmpty) ...[
                      pw.SizedBox(height: 24),
                      _sectionTitle('Fichiers inclus dans ce dossier', primaryColor, accentColor),
                      pw.SizedBox(height: 12),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: borderColor),
                        ),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: pw.Column(children: [
                          ...demande.submittedForms
                              .where((f) => f.pdfUrl.isNotEmpty)
                              .map((f) => _ligneFichier(
                                    f.label.isNotEmpty ? f.label : 'Document',
                                    accentColor,
                                  )),
                          ...demande.requiredDocuments
                              .where((d) => d.id.isNotEmpty)
                              .map((d) => _ligneFichier(
                                    d.label.isNotEmpty ? d.label : 'Pièce jointe',
                                    accentColor,
                                  )),
                        ]),
                      ),
                    ],

                    pw.Spacer(),

                    // Pied de page
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 16),
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: borderColor),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(
                            children: [
                              if (logo != null) ...[
                                pw.Image(logo, width: 16, height: 16),
                                pw.SizedBox(width: 6),
                              ],
                              pw.Row(children: [
                                pw.Text('SECURE ',
                                  style: pw.TextStyle(
                                    color: primaryColor,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text('FORMS',
                                  style: pw.TextStyle(
                                    color: accentColor,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ]),
                            ],
                          ),
                          pw.Text(
                            'Généré le $dateStr',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final file = File('${dossier.path}/00_resume.pdf');
    await file.writeAsBytes(await pdf.save());
  }

  static pw.Widget _sectionTitle(String title, PdfColor primary, PdfColor accent) =>
    pw.Row(
      children: [
        pw.Container(width: 4, height: 18, color: accent),
        pw.SizedBox(width: 10),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: primary,
          ),
        ),
      ],
    );

  static pw.Widget _ligneInfo(String label, String valeur, PdfColor valeurColor) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.Text(
            valeur,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: valeurColor,
            ),
          ),
        ],
      ),
    );

  static pw.Widget _divider(PdfColor color) => pw.Container(
    height: 0.5,
    color: color,
  );

  static pw.Widget _ligneFichier(String nom, PdfColor accentColor) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 30,
            height: 18,
            decoration: pw.BoxDecoration(
              color: accentColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                'PDF',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              nom,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );

  static String _labelStatut(String status) {
    switch (status.toUpperCase()) {
      case 'EN_COURS':  return 'En cours';
      case 'VALIDEE':
      case 'VALIDE':    return 'Validée';
      case 'REJETEE':
      case 'REJETE':    return 'Rejetée';
      case 'BROUILLON': return 'Brouillon';
      default:          return 'En attente';
    }
  }

  static String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();

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

class _Fichier {
  final String nom;
  final String url;
  final bool useToken;
  const _Fichier({required this.nom, required this.url, required this.useToken});
}

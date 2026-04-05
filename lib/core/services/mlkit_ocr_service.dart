import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Résultat de l'extraction OCR sur un document
class OcrDocumentResult {
  final String? issueDate;
  final String? expirationDate;
  final String rawText;

  const OcrDocumentResult({
    this.issueDate,
    this.expirationDate,
    required this.rawText,
  });

  bool get hasDates => issueDate != null || expirationDate != null;
}

class MlKitOcrService {
  static Future<OcrDocumentResult> extractDatesFromDocument(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await textRecognizer.processImage(inputImage);
      final rawText = _cleanOcrText(recognized.text);

      if (rawText.isEmpty) return OcrDocumentResult(rawText: rawText);

      // 1. Chercher par mots-clés
      String? issueDate = _findDateByKeywords(rawText, _issuanceKeywords);
      String? expirationDate = _findDateByKeywords(rawText, _expirationKeywords);

      // 2. Fallback : toutes les dates filtrées
      if (issueDate == null || expirationDate == null) {
        final allDates = _extractAllDates(rawText);
        allDates.sort();
        // Exclure les dates déjà trouvées
        final remaining = allDates.where((d) {
          final formatted = _formatDate(d);
          return formatted != issueDate && formatted != expirationDate;
        }).toList();

        if (issueDate == null && expirationDate == null) {
          // 3 dates ou plus : ignorer la plus ancienne (naissance)
          if (remaining.length >= 3) {
            issueDate = _formatDate(remaining[remaining.length - 2]);
            expirationDate = _formatDate(remaining.last);
          } else if (remaining.length == 2) {
            issueDate = _formatDate(remaining.first);
            expirationDate = _formatDate(remaining.last);
          } else if (remaining.length == 1) {
            final d = remaining.first;
            if (d.isAfter(DateTime.now())) {
              expirationDate = _formatDate(d);
            } else {
              issueDate = _formatDate(d);
            }
          }
        } else if (issueDate != null && expirationDate == null) {
          // On a la délivrance, chercher l'expiration parmi les dates futures
          final future = remaining.where((d) => d.isAfter(DateTime.now())).toList();
          if (future.isNotEmpty) {
            future.sort();
            expirationDate = _formatDate(future.first);
          } else if (remaining.isNotEmpty) {
            // Pas de date future : prendre la plus récente différente de issueDate
            expirationDate = _formatDate(remaining.last);
          }
        } else if (issueDate == null && expirationDate != null) {
          final past = remaining.where((d) => d.isBefore(DateTime.now()) && d.year >= 2000).toList();
          if (past.isNotEmpty) {
            past.sort();
            issueDate = _formatDate(past.last);
          }
        }
      }


      return OcrDocumentResult(issueDate: issueDate, expirationDate: expirationDate, rawText: rawText);
    } catch (e) {
      print('[MlKitOcrService] Erreur: $e');
      return OcrDocumentResult(rawText: '');
    } finally {
      textRecognizer.close();
    }
  }

  /// Nettoie le texte OCR : corrige les confusions O/0 et slashs manquants dans les dates
  static String _cleanOcrText(String text) {
    // Étape 1 : remplacer O/o par 0 dans tout contexte ressemblant à une date
    // Pattern large : 1-2 chiffres/lettres, séparateur, 1-2 chiffres/lettres, séparateur, 2-4 chiffres/lettres
    var cleaned = text.replaceAllMapped(
      RegExp(r'\b([0-9OoIl]{1,2})[./\-]([0-9OoIl]{1,2})[./\-]([0-9OoIl]{2,4})\b'),
      (m) {
        final fixed = m.group(0)!
            .replaceAll(RegExp(r'[Oo]'), '0')
            .replaceAll(RegExp(r'[Il]'), '1');
        return fixed;
      },
    );
    // Étape 2 : slash manquant entre mois et année (ex: 07/1012021 → 07/10/2021)
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(\d{1,2})[./](\d{2})(\d{4})\b'),
      (m) => '${m.group(1)}/${m.group(2)}/${m.group(3)}',
    );
    return cleaned;
  }

  // Mots-clés pour la date de délivrance
  static const _issuanceKeywords = [
    'delivrance', 'délivrance', 'delivr', 'délivr',
    'issue', 'issued', 'issuance',
    'date de début', 'debut', 'début',
    'valid from', 'valable du', 'valable depuis',
    '4b', '4a', // codes MRZ permis
  ];

  // Mots-clés pour la date d'expiration
  static const _expirationKeywords = [
    'expiration', 'expiry', 'expire', 'expir',
    'validité', 'validite', 'valid until', 'valid to',
    'fin de validité', 'date limite',
    'valable jusqu', 'valable au',
    '4c', // code MRZ permis
  ];

  /// Cherche la date qui SUIT le mot-clé (dans les 80 caractères après)
  static String? _findDateByKeywords(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    final dateRegex = RegExp(r'(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})');

    for (final kw in keywords) {
      int searchFrom = 0;
      while (true) {
        final kwIndex = lower.indexOf(kw.toLowerCase(), searchFrom);
        if (kwIndex == -1) break;

        // Chercher la première date dans les 80 caractères APRES le mot-clé
        final afterKw = text.substring((kwIndex + kw.length).clamp(0, text.length));
        final contextEnd = afterKw.length.clamp(0, 80);
        final context = afterKw.substring(0, contextEnd);

        final match = dateRegex.firstMatch(context);
        if (match != null) {
          final dt = _parseDate(match);
          if (dt != null) {
  
            return _formatDate(dt);
          }
        }
        searchFrom = kwIndex + 1;
      }
    }
    return null;
  }

  /// Extrait toutes les dates valides du texte (année entre 2000 et 2060)
  static List<DateTime> _extractAllDates(String text) {
    final regex = RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})\b');
    final results = <DateTime>[];
    for (final match in regex.allMatches(text)) {
      final dt = _parseDate(match);
      if (dt != null) results.add(dt);
    }

    return results;
  }

  static DateTime? _parseDate(RegExpMatch match) {
    try {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      var year = int.parse(match.group(3)!);
      if (year < 100) year += 2000;
      if (day >= 1 && day <= 31 && month >= 1 && month <= 12 &&
          year >= 2000 && year <= 2060) {
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

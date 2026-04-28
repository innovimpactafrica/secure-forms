import 'dart:io';
import 'dart:convert';

void main() {
  for (final path in [
    'assets/translations/fr.json',
    'assets/translations/en.json',
  ]) {
    final file = File(path);
    final bytes = file.readAsBytesSync();
    // Décoder en latin1 pour préserver tous les bytes
    var content = latin1.decode(bytes);
    // Corriger le backtick-n littéral
    content = content.replaceAll('`n', '\n');
    // Réécrire en UTF-8
    file.writeAsBytesSync(utf8.encode(content));
    print('Fixed: $path');
  }
}

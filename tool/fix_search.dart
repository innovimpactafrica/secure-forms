import 'dart:io';

void main() {
  final file = File('lib/features/client/presentation/widgets/recent_demandes_section.dart');
  final lines = file.readAsLinesSync();
  final result = <String>[];
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim() == 'color: AppColors.greyShade100,') continue;
    result.add(lines[i]);
  }
  file.writeAsStringSync(result.join('\n'));
  print('Done: removed greyShade100 line');
}

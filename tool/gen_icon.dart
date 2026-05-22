import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodeImage(File('assets/images/Design sans titre(10).png').readAsBytesSync())!;

  const canvasSize = 1024;

  // iOS : logo à 95% (inchangé)
  final logoSizeIos = (canvasSize * 0.95).round();
  final canvasIos = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvasIos, color: img.ColorRgba8(255, 255, 255, 255));
  final resizedIos = img.copyResize(src, width: logoSizeIos, height: logoSizeIos, maintainAspect: true);
  img.compositeImage(canvasIos, resizedIos,
      dstX: (canvasSize - resizedIos.width) ~/ 2,
      dstY: (canvasSize - resizedIos.height) ~/ 2);
  File('assets/images/qff_icon.png').writeAsBytesSync(img.encodePng(canvasIos));
  print('iOS done: qff_icon.png ${canvasSize}x${canvasSize}, logo ${resizedIos.width}x${resizedIos.height}');

  // Android foreground : logo à 60%
  final logoSizeAndroid = (canvasSize * 0.60).round();
  final canvasAndroid = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvasAndroid, color: img.ColorRgba8(255, 255, 255, 255)); // blanc
  final resizedAndroid = img.copyResize(src, width: logoSizeAndroid, height: logoSizeAndroid, maintainAspect: true);
  img.compositeImage(canvasAndroid, resizedAndroid,
      dstX: (canvasSize - resizedAndroid.width) ~/ 2,
      dstY: (canvasSize - resizedAndroid.height) ~/ 2);
  File('assets/images/qff_icon_android.png').writeAsBytesSync(img.encodePng(canvasAndroid));
  print('Android done: qff_icon_android.png ${canvasSize}x${canvasSize}, logo ${resizedAndroid.width}x${resizedAndroid.height}');
}

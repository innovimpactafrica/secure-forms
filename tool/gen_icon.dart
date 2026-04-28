import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodeImage(File('assets/images/QFF.png').readAsBytesSync())!;

  const canvasSize = 1024;
  final logoSize = (canvasSize * 0.50).round();

  final canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: img.ColorRgba8(255, 255, 255, 255));

  final resized = img.copyResize(src, width: logoSize, height: logoSize, maintainAspect: true);

  final offsetX = (canvasSize - resized.width) ~/ 2;
  final offsetY = (canvasSize - resized.height) ~/ 2;

  img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);

  File('assets/images/qff_icon.png').writeAsBytesSync(img.encodePng(canvas));
  print('Done: qff_icon.png ${canvasSize}x${canvasSize}, logo ${resized.width}x${resized.height}');
}

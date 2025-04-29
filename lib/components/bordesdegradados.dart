import 'package:flutter/material.dart';

class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  void paint(Canvas canvas, Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (shape == BoxShape.rectangle) {
      if (borderRadius != null) {
        canvas.drawRRect(borderRadius.toRRect(rect), paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    } else {
      canvas.drawCircle(rect.center, rect.width / 2, paint);
    }
  }

  @override
  bool get isUniform => true;
  
  @override
  ShapeBorder scale(double t) {
    throw UnimplementedError();
  }
}

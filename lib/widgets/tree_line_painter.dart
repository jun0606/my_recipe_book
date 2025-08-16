import 'package:flutter/material.dart';

class TreeLinePainter extends CustomPainter {
  final int depth;
  final bool hasChild;

  TreeLinePainter({required this.depth, required this.hasChild});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    // 수직선 그리기 (자식이 있는 경우)
    if (hasChild) {
      canvas.drawLine(Offset(depth * 20.0 + 12, 0), Offset(depth * 20.0 + 12, size.height), paint);
    }

    // 수평선 그리기 (자식 레시피인 경우)
    if (depth > 0) {
      canvas.drawLine(Offset(depth * 20.0 - 8, size.height / 2), Offset(depth * 20.0 + 12, size.height / 2), paint);
      canvas.drawLine(Offset(depth * 20.0 - 8, size.height / 2), Offset(depth * 20.0 - 8, 0), paint); // 부모로부터 내려오는 수직선
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
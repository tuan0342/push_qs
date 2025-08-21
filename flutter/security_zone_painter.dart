// security_zone_painter.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SecurityZonePainter extends CustomPainter {
  final List<LatLng> points;
  final MapController mapController;

  SecurityZonePainter({
    required this.points,
    required this.mapController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 3) return;

    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Convert LatLng to screen points
    final screenPoints = points
        .map((latLng) => mapController.project(latLng))
        .map((point) => Offset(
              point.x - mapController.pixelOrigin.x,
              point.y - mapController.pixelOrigin.y,
            ))
        .toList();

    path.moveTo(screenPoints[0].dx, screenPoints[0].dy);
    for (int i = 1; i < screenPoints.length; i++) {
      path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }
    path.close(); // close the polygon

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

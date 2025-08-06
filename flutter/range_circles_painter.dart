import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RangeCirclesPainter extends CustomPainter {
  final LatLng center;
  final List<double> radiiInKm;
  final double zoom;
  final double width;
  final double height;

  RangeCirclesPainter({
    required this.center,
    required this.radiiInKm,
    required this.zoom,
    required this.width,
    required this.height,
  });

  double _metersPerPixel(double latitude, double zoom) {
    const earthCircumference = 40075016.686; // meters
    final scale = 1 << zoom.toInt();
    return earthCircumference * cos(latitude * pi / 180) / (256 * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerOffset = Offset(width / 2, height / 2);
    final metersPerPixel = _metersPerPixel(center.latitude, zoom);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < radiiInKm.length; i++) {
      final radiusInMeters = radiiInKm[i] * 1000;
      final radiusInPixels = radiusInMeters / metersPerPixel;

      paint.color = Colors.blue.withOpacity(1 - i * 0.15); // đậm hơn ở vòng trong

      canvas.drawCircle(centerOffset, radiusInPixels, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

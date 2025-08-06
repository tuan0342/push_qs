import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AzimuthLinesPainter extends CustomPainter {
  final LatLng center;
  final MapController mapController;

  AzimuthLinesPainter({
    required this.center,
    required this.mapController,
  });

  // Tính bán kính (pixel) từ bán kính thực (km)
  double _calculateRadiusInPixels(double radiusInKm, double latitude, double zoom) {
    const earthRadius = 6378137.0;
    final radiusInMeters = radiusInKm * 1000;
    final scale = 256 * pow(2, zoom);
    return radiusInMeters / (2 * pi * earthRadius) * scale / cos(latitude * pi / 180);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset? centerOffset = mapController.camera.latLngToScreenOffset(center);
    if (centerOffset == null) return;

    final zoom = mapController.camera.zoom;
    final latitude = center.latitude;
    final radius = _calculateRadiusInPixels(15, latitude, zoom);

    final Paint paint = Paint()
      ..color = const Color(0xFF0066CC) // Xanh nước biển đậm
      ..strokeWidth = 1.5;

    // Vẽ 30 đường cách nhau 12 độ
    for (int i = 0; i < 30; i++) {
      final angleDegrees = i * 12;
      final angleRadians = (angleDegrees - 90) * pi / 180; // gốc là phương Bắc (0°)

      final dx = radius * cos(angleRadians);
      final dy = radius * sin(angleRadians);

      final endPoint = Offset(centerOffset.dx + dx, centerOffset.dy + dy);
      canvas.drawLine(centerOffset, endPoint, paint);
    }

    // Optional: vẽ vòng tròn bán kính 15km
    final circlePaint = Paint()
      ..color = const Color(0xFF0066CC).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(centerOffset, radius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

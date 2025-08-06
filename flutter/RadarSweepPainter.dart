import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RadarSweepPainter extends CustomPainter {
  final LatLng center;
  final MapController mapController;
  final double startAngleDegrees; // cập nhật theo thời gian nếu cần

  RadarSweepPainter({
    required this.center,
    required this.mapController,
    required this.startAngleDegrees,
  });

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

    final startAngleRad = (startAngleDegrees - 90) * pi / 180;
    final sweepAngleRad = 2 * pi / 180; // 2 độ

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF3D00).withOpacity(0.4), // đỏ cam nhạt ở tâm
          const Color(0xFFFF3D00).withOpacity(0.0), // trong suốt ở rìa
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: centerOffset, radius: radius))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(centerOffset.dx, centerOffset.dy)
      ..arcTo(
        Rect.fromCircle(center: centerOffset, radius: radius),
        startAngleRad,
        sweepAngleRad,
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter oldDelegate) =>
      oldDelegate.startAngleDegrees != startAngleDegrees;
}

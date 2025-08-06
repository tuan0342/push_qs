import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class RangeCirclesPainter extends CustomPainter {
  final LatLng center;
  final List<double> radiiInKm;
  final MapController mapController;

  RangeCirclesPainter({
    required this.center,
    required this.radiiInKm,
    required this.mapController,
  });

  // Hàm tính bán kính theo pixel
  double _calculateRadiusInPixels(double radiusInKm, double latitude, double zoom) {
    const earthRadius = 6378137.0; // Earth radius in meters
    final radiusInMeters = radiusInKm * 1000;
    final scale = 256 * pow(2, zoom);
    return radiusInMeters / (2 * pi * earthRadius) * scale / cos(latitude * pi / 180);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pixelPoint = mapController.latLngToScreenPoint(center);
    if (pixelPoint == null) return;

    final centerOffset = Offset(pixelPoint.x.toDouble(), pixelPoint.y.toDouble());

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final zoom = mapController.camera.zoom;
    final latitude = center.latitude;

    for (int i = 0; i < radiiInKm.length; i++) {
      final radiusInPixels = _calculateRadiusInPixels(radiiInKm[i], latitude, zoom);

      paint.color = Colors.blue.withOpacity(1 - i * 0.15); // nhạt dần theo bán kính

      canvas.drawCircle(centerOffset, radiusInPixels, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RangeCirclesPainter oldDelegate) =>
      oldDelegate.mapController.camera != mapController.camera;
}

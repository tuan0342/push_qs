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

  // km -> pixel theo zoom + vĩ độ hiện tại
  double _radiusPx(double radiusKm, double lat, double zoom) {
    const earthRadius = 6378137.0; // meters
    final meters = radiusKm * 1000;
    final scale = 256 * pow(2, zoom);
    return meters / (2 * pi * earthRadius) * scale / cos(lat * pi / 180);
  }

  static const _lineColor = Color(0xFF0066CC);
  static const _majorAngles = {0, 60, 120, 180, 240, 300}; // vẽ dài hơn

  @override
  void paint(Canvas canvas, Size size) {
    final centerOffset = mapController.camera.latLngToScreenOffset(center);
    if (centerOffset == null) return;

    final zoom = mapController.camera.zoom;
    final lat = center.latitude;
    final baseRadius = _radiusPx(15, lat, zoom);

    // Vẽ vòng 15km
    final circlePaint = Paint()
      ..color = _lineColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(centerOffset, baseRadius, circlePaint);

    // Cấu hình nét vẽ
    final linePaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.6;

    // Vẽ 30 hướng (mỗi 12°)
    for (var i = 0; i < 30; i++) {
      final deg = i * 12; // 0..348 step 12°
      final isMajor = _majorAngles.contains(deg);

      // 0° là phương Bắc -> xoay trục vẽ: (deg - 90) độ
      final rad = (deg - 90) * pi / 180;

      // Độ dài đường: thường = tới vòng tròn, major = vươn ra thêm 10%
      final lineLen = isMajor ? baseRadius * 1.1 : baseRadius;
      final dx = lineLen * cos(rad);
      final dy = lineLen * sin(rad);

      final end = Offset(centerOffset.dx + dx, centerOffset.dy + dy);
      canvas.drawLine(centerOffset, end, linePaint);

      // Label chỉ vẽ cho các góc major
      if (isMajor) {
        _drawAngleLabel(
          canvas: canvas,
          text: '$deg°',
          anchor: end,
          // đẩy label ra ngoài đầu mút một chút cho thoáng
          offsetFromEnd: 10,
          angleRad: rad,
        );
      }
    }
  }

  // Vẽ label có nền mờ để đọc tốt trên nhiều bản đồ
  void _drawAngleLabel({
    required Canvas canvas,
    required String text,
    required Offset anchor,
    required double angleRad,
    double offsetFromEnd = 8,
  }) {
    // Đẩy label ra ngoài theo hướng của tia
    final nx = cos(angleRad);
    final ny = sin(angleRad);
    final pos = Offset(
      anchor.dx + nx * offsetFromEnd,
      anchor.dy + ny * offsetFromEnd,
    );

    // Đo kích thước text
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white, // chữ trắng cho dễ đọc
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
    final rect = Rect.fromLTWH(
      pos.dx,
      pos.dy - tp.height / 2, // canh giữa theo chiều dọc
      tp.width + padding.horizontal,
      tp.height + padding.vertical,
    );

    // Nền mờ + viền mảnh để nổi trên mọi nền
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.45);
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Vẽ text bên trong
    final textOffset = Offset(
      rect.left + padding.left,
      rect.top + padding.top + (tp.height - tp.height) / 2,
    );
    tp.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

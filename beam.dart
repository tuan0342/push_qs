import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/beam_model.dart';

/// CustomPainter để vẽ các BEAM dạng sector (quạt) theo:
/// - tâm: (latitude, longitude)
/// - bán kính: distance (km)
/// - góc bắt đầu/kết thúc: angle_start / angle_end (độ, bearing: 0 = Bắc, chiều quay thuận kim)
class BeamPainter extends CustomPainter {
  BeamPainter({
    required this.beams,
    required this.mapController,
  });

  final List<Beam> beams;
  final MapController mapController;

  // ---- CONFIG ----
  static const double _strokeWidth = 2.0;
  static const double _opacityWeak = 0.35; // status=2
  static const double _opacityStrong = 0.85; // status=3
  static const int _arcSamples = 64; // số điểm để nội suy cung nếu cần vẽ path theo screen

  @override
  void paint(Canvas canvas, Size size) {
    if (beams.isEmpty) return;

    for (final beam in beams) {
      // status=1 thì ẩn hoàn toàn
      if (_statusToVisibility(beam.status) == _Visibility.hidden) continue;

      // Tính màu theo type & status
      final baseColor = _colorByType(beam.type);
      final opacity = _opacityByStatus(beam.status);
      final fillPaint = Paint()
        ..color = baseColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = baseColor.withOpacity(math.min(1, opacity + 0.1))
        ..strokeWidth = _strokeWidth
        ..style = PaintingStyle.stroke;

      // Tâm theo screen (pixel)
      final centerScreen = mapController.camera.latLngToScreenOffset(
        LatLng(beam.latitude, beam.longitude),
      );

      // Bán kính (pixel) từ distance (km)
      final radiusPx = _radiusPixelsFromKm(
        centerLat: beam.latitude,
        distanceKm: beam.distance,
      );
      if (radiusPx <= 0) continue;

      // Chuyển góc geo (bearing) sang góc canvas (radian)
      final startRad = _bearingDegToCanvasRad(beam.angleStart);
      final endRad = _bearingDegToCanvasRad(beam.angleEnd);

      // Sweep angle theo chiều kim đồng hồ
      final sweep = _sweepAngle(startRad, endRad);
      if (sweep.abs() < 0.0001) continue; // góc quá nhỏ

      // Vẽ sector bằng Path (ổn định khi zoom lớn/nhỏ)
      final path = Path()
        ..moveTo(centerScreen.dx, centerScreen.dy);

      // Nội suy cung tròn bằng nhiều điểm (tránh vấn đề rect khi map xoay/tile scale)
      final samples = math.max(8, (_arcSamples * (sweep.abs() / (2 * math.pi))).round());
      for (int i = 0; i <= samples; i++) {
        final t = i / samples;
        final a = startRad + sweep * t;
        final x = centerScreen.dx + radiusPx * math.cos(a);
        final y = centerScreen.dy + radiusPx * math.sin(a);
        if (i == 0) {
          path.lineTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BeamPainter oldDelegate) {
    // Repaint khi:
    // - list beams thay đổi tham chiếu hoặc nội dung quan trọng (id/angle/radius…) thay đổi
    // - mapController camera thay đổi (FlutterMap sẽ rebuild layer)
    if (identical(oldDelegate.beams, beams)) return false;
    if (oldDelegate.beams.length != beams.length) return true;
    for (int i = 0; i < beams.length; i++) {
      final a = beams[i];
      final b = oldDelegate.beams[i];
      if (a.id != b.id ||
          a.latitude != b.latitude ||
          a.longitude != b.longitude ||
          a.distance != b.distance ||
          a.angleStart != b.angleStart ||
          a.angleEnd != b.angleEnd ||
          a.status != b.status ||
          a.type != b.type) {
        return true;
      }
    }
    return false;
  }

  // -------------------- Helpers --------------------

  /// Màu theo type = 1..4:
  /// 1: đỏ, 2: tím, 3: xanh, 4: vàng
  Color _colorByType(BeamType type) {
    // Nếu BeamType của bạn là số (1..4) thì map lại ở đây.
    // Ví dụ: unknown=0, cheAp=1, radar=2, ... bạn có thể chỉnh theo backend thực tế.
    switch (type) {
      case BeamType.unknown:
        return Colors.grey;
      case BeamType.cheAp: // giả sử = 1
        return Colors.red;
      case BeamType.radar: // giả sử = 2
        return Colors.purple;
      case BeamType.third: // nếu bạn có thêm enum 3
        return Colors.blue;
      case BeamType.fourth: // nếu bạn có thêm enum 4
        return Colors.yellow.shade700;
    }
  }

  /// Opacity theo status:
  /// 1: ẩn (đã skip), 2: nhạt, 3: đậm
  double _opacityByStatus(BeamStatus status) {
    switch (status) {
      case BeamStatus.unknown: // có thể coi như ẩn nhẹ
        return _opacityWeak;
      case BeamStatus.inactive: // 1 -> ẩn: nhưng ta đã skip ở trên
        return 0.0;
      case BeamStatus.ready: // 2
        return _opacityWeak;
      case BeamStatus.active: // 3
        return _opacityStrong;
    }
  }

  _Visibility _statusToVisibility(BeamStatus status) {
    // status = 1 => ẩn
    if (status == BeamStatus.inactive) return _Visibility.hidden;
    return _Visibility.visible;
  }

  /// Chuyển bearing độ (0=Bắc, tăng theo chiều kim đồng hồ) sang góc Canvas rad
  /// Canvas: 0 rad là trục X dương (hướng phải), tăng theo chiều kim đồng hồ
  /// Bearing 0 (Bắc) -> Canvas -pi/2 (hướng lên)
  double _bearingDegToCanvasRad(double bearingDeg) {
    final rad = bearingDeg * math.pi / 180.0;
    return rad - math.pi / 2.0;
  }

  /// Tính sweep angle từ start đến end theo chiều kim đồng hồ (dương)
  double _sweepAngle(double startRad, double endRad) {
    double sweep = endRad - startRad;
    // chuẩn hóa vào [0, 2pi)
    while (sweep <= 0) sweep += 2 * math.pi;
    while (sweep > 2 * math.pi) sweep -= 2 * math.pi;
    return sweep;
  }

  /// Bán kính theo pixel từ distance km tại vĩ độ `centerLat`.
  /// Cách làm: tính điểm đích (latLng) theo quãng đường `distanceKm` dọc hướng Đông (bearing=90),
  /// rồi lấy khoảng cách pixel giữa tâm và điểm đích.
  double _radiusPixelsFromKm({
    required double centerLat,
    required double distanceKm,
  }) {
    if (distanceKm <= 0) return 0;

    final center = LatLng(centerLat, 0); // kinh độ tạm không quan trọng khi đo pixel
    final dest = _destinationPoint(center, distanceKm, 90); // đi về phía Đông

    final p0 = mapController.camera.latLngToScreenOffset(center);
    final p1 = mapController.camera.latLngToScreenOffset(dest);

    final dx = p1.dx - p0.dx;
    final dy = p1.dy - p0.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Tính điểm đến từ lat/lng + distance(km) + bearing(độ)
  /// Dùng công thức geodesic (bán kính Trái Đất ~ 6371 km)
  LatLng _destinationPoint(LatLng start, double distanceKm, double bearingDeg) {
    const R = 6371.0; // km
    final bearing = bearingDeg * math.pi / 180.0;

    final φ1 = start.latitude * math.pi / 180.0;
    final λ1 = start.longitude * math.pi / 180.0;
    final δ = distanceKm / R;

    final sinφ1 = math.sin(φ1);
    final cosφ1 = math.cos(φ1);
    final sinδ = math.sin(δ);
    final cosδ = math.cos(δ);
    final sinθ = math.sin(bearing);
    final cosθ = math.cos(bearing);

    final sinφ2 = sinφ1 * cosδ + cosφ1 * sinδ * cosθ;
    final φ2 = math.asin(sinφ2);
    final y = sinθ * sinδ * cosφ1;
    final x = cosδ - sinφ1 * sinφ2;
    final λ2 = λ1 + math.atan2(y, x);

    final lat = φ2 * 180.0 / math.pi;
    final lon = (λ2 * 180.0 / math.pi + 540) % 360 - 180; // normalize [-180,180]
    return LatLng(lat, lon);
  }
}

enum _Visibility { visible, hidden }

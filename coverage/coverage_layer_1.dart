// CoveragePainter.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng, Distance;

/// ==== Models (theo mô tả bạn đưa) ====

class Coordinate {
  final double x; // longitude
  final double y; // latitude

  const Coordinate({required this.x, required this.y});
}

class Coverage {
  final Coordinate centerCoordinate; // lon/lat
  final List<Coordinate> blindCoordinates; // lon/lat
  final List<Coordinate> detectCoordinates; // lon/lat
  final double blindRadius; // meters
  final double detectRadius; // meters

  const Coverage({
    required this.centerCoordinate,
    required this.blindCoordinates,
    required this.detectCoordinates,
    required this.blindRadius,
    required this.detectRadius,
  });
}

/// CustomPainter vẽ merged coverage giống TSX:
/// - Donut = detectUnion \ blindVisible
/// - Viền detect (đã merge)
/// - Label độ cao (height -> "{height}m")
/// - (Tuỳ chọn) chấm các điểm mẫu blind/detect
class CoveragePainter extends CustomPainter {
  final List<Coverage> coverageList;
  final bool showPoints;
  final double height; // meters -> sẽ in "{height}m"
  final MapController controller; // 👈 MapController của flutter_map

  CoveragePainter({
    required this.coverageList,
    required this.showPoints,
    required this.height,
    required this.controller,
  });

  // Màu sắc tương tự code TSX
  static const _detectColor = Color(0xFF16A34A);
  static const _blindStroke = Color(0xFF166534);
  static const _detectStroke = Color(0xFF14532D);

  // ===== Helpers: quy đổi & path ops =====

  /// WebMercator meters-per-pixel tại vĩ độ [latDeg] và zoom [z].
  /// công thức: mpp = cos(lat)*2*pi*R / (tileSize * 2^z)
  // double _metersPerPixel(
  //     {required double latDeg, required double zoom, double tileSize = 256}) {
  //   const R = 6378137.0; // m (WGS84)
  //   final latRad = latDeg * math.pi / 180.0;
  //   const earthCircumference = 2 * math.pi * R;
  //   final denom = tileSize * math.pow(2.0, zoom);
  //   return (math.cos(latRad) * earthCircumference) / denom;
  // }

  // /// Quy đổi bán kính theo mét -> pixel tại vĩ độ [latDeg] theo camera hiện tại.
  // double _metersToPixels(double meters, double latDeg) {
  //   final cam = controller.camera;
  //   final mpp = _metersPerPixel(latDeg: latDeg, zoom: cam.zoom);
  //   return meters / mpp;
  // }

  double _radiusMetersToPixelsAt(LatLng center, double meters) {
    final cam = controller.camera;

    // 1) Điểm tâm & 2) điểm mép cách 'meters' theo hướng Bắc (bearing=0)
    final dest = const Distance().offset(center, meters, 0);

    // 3) Đổi ra màn hình
    final p0 = cam.latLngToScreenOffset(center);
    final p1 = cam.latLngToScreenOffset(dest);

    // 4) Khoảng cách pixel
    return (Offset(p1.dx.toDouble(), p1.dy.toDouble()) -
            Offset(p0.dx.toDouble(), p0.dy.toDouble()))
        .distance;
  }

  /// Đổi lon/lat -> Offset màn hình (pixel)
  Offset _llToScreen(double lon, double lat) {
    final cam = controller.camera;
    final off = cam.latLngToScreenOffset(LatLng(lat, lon));
    return Offset(off.dx.toDouble(), off.dy.toDouble());
  }

  Path _circlePath(Offset c, double r) =>
      Path()..addOval(Rect.fromCircle(center: c, radius: r));

  Path? _unionAll(List<Path> paths) {
    if (paths.isEmpty) return null;
    var acc = paths.first;
    for (var i = 1; i < paths.length; i++) {
      acc = Path.combine(PathOperation.union, acc, paths[i]);
    }
    return acc;
  }

  Path? _unionOthers(List<Path> paths, int skipIdx) {
    Path? acc;
    for (var i = 0; i < paths.length; i++) {
      if (i == skipIdx) continue;
      acc = (acc == null)
          ? paths[i]
          : Path.combine(PathOperation.union, acc, paths[i]);
    }
    return acc;
  }

  void _drawCenteredText(Canvas canvas, String text, Offset pos,
      {TextStyle style = const TextStyle(
          fontSize: 12,
          color: Color(0xFF166534),
          fontWeight: FontWeight.w600)}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final topLeft = pos - Offset(tp.width / 2, tp.height / 2);

    // "Halo" trắng mờ phía sau để dễ đọc như text-halo
    final halo = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          color: Colors.white,
          foreground: Paint()
            ..color = Colors.white
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    halo.paint(canvas, topLeft);
    tp.paint(canvas, topLeft);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (coverageList.isEmpty) return;

    // ===== Bước 1: Build paths từ lon/lat + radius(m) theo camera hiện tại =====
    final blindPaths = <Path>[];
    final detectPaths = <Path>[];
    final blindPointsPx = <Offset>[];
    final detectPointsPx = <Offset>[];

    for (final c in coverageList) {
      // Center in screen px
      final center = _llToScreen(c.centerCoordinate.x, c.centerCoordinate.y);

      // Radius: meters -> pixels (theo vĩ độ của center)
      // final blindRpx = _metersToPixels(c.blindRadius, c.centerCoordinate.y);
      // final detectRpx = _metersToPixels(c.detectRadius, c.centerCoordinate.y);
      final blindRpx = _radiusMetersToPixelsAt(
          LatLng(c.centerCoordinate.x, c.centerCoordinate.y), c.blindRadius);
      final detectRpx = _radiusMetersToPixelsAt(
          LatLng(c.centerCoordinate.x, c.centerCoordinate.y), c.blindRadius);

      blindPaths.add(_circlePath(center, blindRpx));
      detectPaths.add(_circlePath(center, detectRpx));

      if (showPoints) {
        // các điểm mẫu -> px
        for (final p in c.blindCoordinates) {
          blindPointsPx.add(_llToScreen(p.x, p.y));
        }
        for (final p in c.detectCoordinates) {
          detectPointsPx.add(_llToScreen(p.x, p.y));
        }
      }
    }

    // ===== 2) Union tất cả detect =====
    final detectUnion = _unionAll(detectPaths);

    // ===== 3) blindVisible = union_i( blind_i \ union_j!=i(detect_j) ) =====
    Path? blindVisibleUnion;
    for (var i = 0; i < blindPaths.length; i++) {
      final blindI = blindPaths[i];
      final othersDetectU = _unionOthers(detectPaths, i);
      final visibleI = (othersDetectU == null)
          ? blindI
          : Path.combine(PathOperation.difference, blindI, othersDetectU);

      blindVisibleUnion = (blindVisibleUnion == null)
          ? visibleI
          : Path.combine(PathOperation.union, blindVisibleUnion, visibleI);
    }

    // ===== 4) Donut = detectUnion \ blindVisibleUnion =====
    Path? donutPath;
    if (detectUnion != null) {
      donutPath = (blindVisibleUnion == null)
          ? detectUnion
          : Path.combine(
              PathOperation.difference, detectUnion, blindVisibleUnion);
    }

    // ===== 5) VẼ =====

    // 5.1) Donut fill
    if (donutPath != null) {
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = _detectColor.withAlpha(30); // ~ 0.1
      canvas.drawPath(donutPath, fill);
    }

    // 5.2) Detect outline (merged)
    if (detectUnion != null) {
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _detectStroke;
      canvas.drawPath(detectUnion, outline);
    }

    // 5.3) Points (tuỳ chọn)
    if (showPoints) {
      final blindFill = Paint()..color = const Color(0xFF0EA5E9);
      final blindBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _blindStroke;

      final detectFill = Paint()..color = _detectColor;
      final detectBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _detectStroke;

      for (final p in blindPointsPx) {
        canvas.drawCircle(p, 2, blindFill);
        canvas.drawCircle(p, 2, blindBorder);
      }
      for (final p in detectPointsPx) {
        canvas.drawCircle(p, 2, detectFill);
        canvas.drawCircle(p, 2, detectBorder);
      }
    }

    // 5.4) Label "{height}m" dọc biên detect-merged (lấy mid mỗi contour)
    if (detectUnion != null) {
      final metrics = detectUnion.computeMetrics(forceClosed: false).toList();
      for (final m in metrics) {
        final pos = m.getTangentForOffset(m.length * 0.5)?.position;
        if (pos != null) {
          _drawCenteredText(
            canvas,
            '${height.toStringAsFixed(0)}m',
            pos,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF166534),
              fontWeight: FontWeight.w600,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CoveragePainter oldDelegate) {
    // repaint khi pan/zoom (camera), hoặc dữ liệu/flag thay đổi
    // Lưu ý: MapController không so sánh được, nên luôn repaint khi coverageList thay đổi.
    return oldDelegate.coverageList != coverageList ||
        oldDelegate.showPoints != showPoints ||
        oldDelegate.height != height ||
        oldDelegate.controller.camera != controller.camera;
  }
}

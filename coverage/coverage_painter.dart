// CoveragePainter.dart
import 'package:flutter/material.dart';

/// ==== Models (theo mô tả bạn đưa) ====

class Coordinate {
  final double x;
  final double y;

  const Coordinate({required this.x, required this.y});

  Offset toOffset() => Offset(x, y);
}

class Coverage {
  final Coordinate centerCoordinate;
  final List<Coordinate> blindCoordinates;
  final List<Coordinate> detectCoordinates;
  final double blindRadius; // pixel radius (đã quy đổi)
  final double detectRadius; // pixel radius (đã quy đổi)

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
/// - Label độ cao chiều phủ (heightLabel, ví dụ 120 -> "120m")
/// - (Tuỳ chọn) điểm blind/detect
class CoveragePainter extends CustomPainter {
  final List<Coverage> coverageList;
  final bool showPoints;
  final double height; // mét, sẽ in "{height}m"

  CoveragePainter({
    required this.coverageList,
    required this.showPoints,
    required this.height,
  });

  // Màu sắc tương đương TSX
  static const _detectColor = Color(0xFF16A34A); // DETECT_COLOR
  static const _blindStroke = Color(0xFF166534);
  static const _detectStroke = Color(0xFF14532D);

  Path _circlePath(Offset c, double r) =>
      Path()..addOval(Rect.fromCircle(center: c, radius: r));

  Path? _unionAll(List<Path> paths) {
    if (paths.isEmpty) return null;
    Path acc = paths.first;
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
      )}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    // Tính tọa độ hiển thị
    final topLeft = pos - Offset(tp.width / 2, tp.height / 2);
    // halo nhỏ cho dễ đọc
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

    /// --- Bước 1: Tạo path tròn blind (vùng mù) & detect (vùng nhận dạng)
    final blindPaths = <Path>[];
    final detectPaths = <Path>[];
    final blindPointsAll = <Offset>[];
    final detectPointsAll = <Offset>[];

    for (final c in coverageList) {
      final center = c.centerCoordinate.toOffset();
      blindPaths.add(_circlePath(center, c.blindRadius));
      detectPaths.add(_circlePath(center, c.detectRadius));

      if (showPoints) {
        blindPointsAll.addAll(c.blindCoordinates.map((p) => p.toOffset()));
        detectPointsAll.addAll(c.detectCoordinates.map((p) => p.toOffset()));
      }
    }

    /// --- Bước 2: Union tất cả đường nhận dạng (detect)
    final detectUnion = _unionAll(detectPaths);

    /// --- Bước 3: Tính vùng mù (blindVisibleUnion)
    ///   + Bước 3.1: Với mỗi blind_visible_i = blind_i \ union( detect_j != i )
    ///   + Bước 3.2: Tính blindVisibleUnion = union tất cả blind_visible_i
    Path? blindVisibleUnion;
    for (var i = 0; i < blindPaths.length; i++) {
      final blindI = blindPaths[i];
      final othersDetectUnion =
          _unionOthers(detectPaths, i); // union detect của các coverage khác

      final visibleI = (othersDetectUnion == null)
          ? blindI
          : Path.combine(PathOperation.difference, blindI, othersDetectUnion);

      blindVisibleUnion = (blindVisibleUnion == null)
          ? visibleI
          : Path.combine(PathOperation.union, blindVisibleUnion, visibleI);
    }

    /// Bước 4: Donut = detectUnion \ blindVisibleUnion
    Path? donutPath;
    if (detectUnion != null) {
      donutPath = (blindVisibleUnion == null)
          ? detectUnion
          : Path.combine(
              PathOperation.difference, detectUnion, blindVisibleUnion);
    }

    /// ================ VẼ ================

    // Donut fill
    if (donutPath != null) {
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = _detectColor.withAlpha(30);
      canvas.drawPath(donutPath, fill);
    }

    // Detect outline (merged)
    if (detectUnion != null) {
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _detectStroke;
      canvas.drawPath(detectUnion, outline);
    }

    // Points (tuỳ chọn)
    if (showPoints) {
      final blindFill = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF0EA5E9);
      final blindBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _blindStroke;

      final detectFill = Paint()
        ..style = PaintingStyle.fill
        ..color = _detectColor;
      final detectBorder = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _detectStroke;

      for (final p in blindPointsAll) {
        canvas.drawCircle(p, 2, blindFill);
        canvas.drawCircle(p, 2, blindBorder);
      }
      for (final p in detectPointsAll) {
        canvas.drawCircle(p, 2, detectFill);
        canvas.drawCircle(p, 2, detectBorder);
      }
    }

    // Labels "{height}m" dọc đường detectUnion (lấy điểm giữa mỗi contour)
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
    // Repaint khi dữ liệu/flag thay đổi
    return oldDelegate.coverageList != coverageList ||
        oldDelegate.showPoints != showPoints ||
        oldDelegate.height != height;
  }
}

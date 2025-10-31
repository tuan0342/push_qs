// coverage_layers.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:turf_dart/turf_dart.dart' as turf;

/// ==== Models giữ nguyên như bạn ====

class Coordinate {
  final double x; // longitude
  final double y; // latitude
  const Coordinate({required this.x, required this.y});
}

class Coverage {
  final Coordinate centerCoordinate;         // lon/lat (không dùng vẽ circle)
  final List<Coordinate> blindCoordinates;   // polygon lon/lat (khép kín, theo thứ tự)
  final List<Coordinate> detectCoordinates;  // polygon lon/lat (khép kín, theo thứ tự)
  final double blindRadius;                  // meters (không dùng phiên bản polygon)
  final double detectRadius;                 // meters (không dùng phiên bản polygon)

  const Coverage({
    required this.centerCoordinate,
    required this.blindCoordinates,
    required this.detectCoordinates,
    required this.blindRadius,
    required this.detectRadius,
  });
}

/// ==== Widget tạo các Layer cho flutter_map ====
/// - Từ coverageList -> tính:
///   + detectUnion = union(detect_i)
///   + blindVisible = union(blind_i) \ union(detect_i \ blind_i)
///   + donut        = detectUnion \ blindVisible
/// - Vẽ:
///   + PolygonLayer cho 'donut' (fill + outline)
///   + PolygonLayer cho 'blindVisible' (fill nhạt + outline)
///   + MarkerLayer đặt label "{height}m" tại centroid(donut)
///   + (optional) MarkerLayer chấm các điểm mẫu (blind/detect)
class CoverageLayers extends StatelessWidget {
  final List<Coverage> coverageList;
  final bool showPoints;
  final double height; // in ra "{height}m"

  // màu sắc
  static const _detectColor = Color(0xFF16A34A);
  static const _blindStroke = Color(0xFF166534);
  static const _detectStroke = Color(0xFF14532D);

  const CoverageLayers({
    super.key,
    required this.coverageList,
    required this.showPoints,
    required this.height,
  });

  // ====== Helpers: chuyển đổi và tạo hình học turf ======

  /// Đảm bảo ring đóng kín (điểm đầu == điểm cuối)
  List<turf.Position> _closedRingFromCoords(List<Coordinate> coords) {
    if (coords.isEmpty) return const [];
    final ring = <turf.Position>[
      for (final c in coords) turf.Position(c.x, c.y),
    ];
    if (ring.length < 3) return const [];
    final first = ring.first;
    final last = ring.last;
    if (first.lng != last.lng || first.lat != last.lat) {
      ring.add(turf.Position(first.lng, first.lat));
    }
    return ring;
  }

  /// Feature<Polygon> từ danh sách Coordinate (1 outer ring, không holes)
  turf.Feature _featurePolygonFromCoords(List<Coordinate> coords) {
    final ring = _closedRingFromCoords(coords);
    // turf expects: List<List<Position>> (outer + holes)
    final poly = turf.Polygon(coordinates: [ring]);
    return turf.Feature(geometry: poly);
  }

  /// Union nhiều Feature Polygon/MultiPolygon bằng cách reduce
  turf.Feature? _unionAll(List<turf.Feature> polys) {
    if (polys.isEmpty) return null;
    turf.Feature? acc = polys.first;
    for (int i = 1; i < polys.length; i++) {
      acc = turf.union(acc!, polys[i]);
      if (acc == null) return null; // union failed
    }
    return acc;
  }

  /// difference(helper): trả về Feature hoặc null
  turf.Feature? _difference(turf.Feature a, turf.Feature b) {
    return turf.difference(a, b);
  }

  /// convert turf Geometry -> danh sách Polygon (flutter_map) có holes
  /// - Hỗ trợ Polygon & MultiPolygon
  List<Polygon> _geometryToFlutterMapPolygons({
    required turf.Geometry? geometry,
    required Color fillColor,
    required Color borderColor,
    double borderStroke = 2.0,
  }) {
    if (geometry == null) return const [];

    final result = <Polygon>[];

    void addPolygon(List<List<turf.Position>> rings) {
      if (rings.isEmpty) return;

      // outer ring
      final outer = [
        for (final p in rings.first) LatLng(p.lat, p.lng),
      ];

      // holes (nếu có)
      final holes = <List<LatLng>>[];
      if (rings.length > 1) {
        for (int i = 1; i < rings.length; i++) {
          holes.add([for (final p in rings[i]) LatLng(p.lat, p.lng)]);
        }
      }

      result.add(
        Polygon(
          points: outer,
          holePointsList: holes.isEmpty ? null : holes,
          color: fillColor,
          borderColor: borderColor,
          borderStrokeWidth: borderStroke,
          isFilled: true,
          isDotted: false,
        ),
      );
    }

    if (geometry is turf.Polygon) {
      addPolygon(geometry.coordinates);
    } else if (geometry is turf.MultiPolygon) {
      for (final poly in geometry.coordinates) {
        addPolygon(poly);
      }
    } else {
      // Các loại hình học khác không xử lý
    }

    return result;
  }

  /// centroid của geometry (nếu fracaso -> null)
  LatLng? _centroidLatLng(turf.Geometry? geometry) {
    if (geometry == null) return null;
    try {
      final feat = turf.Feature(geometry: geometry);
      final c = turf.centroid(feat);
      final pos = (c.geometry as turf.Point).coordinates;
      return LatLng(pos.lat, pos.lng);
    } catch (_) {
      return null;
    }
  }

  /// Tính blindVisible theo công thức tổng quát:
  /// BlindVisible = union(blind_i) \ union( detect_i \ blind_i )
  turf.Feature? _computeBlindVisible({
    required List<turf.Feature> blindPolys,
    required List<turf.Feature> detectPolys,
  }) {
    if (blindPolys.isEmpty) return null;

    // 1) union blind
    final unionBlind = _unionAll(blindPolys);
    if (unionBlind == null) return null;

    // 2) union donut_i = union( detect_i \ blind_i ), ghép theo index tối thiểu
    final n = detectPolys.length < blindPolys.length
        ? detectPolys.length
        : blindPolys.length;

    final donuts = <turf.Feature>[];
    for (int i = 0; i < n; i++) {
      final di = detectPolys[i];
      final bi = blindPolys[i];
      final donut = _difference(di, bi);
      if (donut != null) donuts.add(donut);
    }

    // nếu không có donut_i nào => blindVisible = unionBlind
    if (donuts.isEmpty) return unionBlind;

    final unionDonut = _unionAll(donuts);
    if (unionDonut == null) return unionBlind;

    // 3) blindVisible = unionBlind \ unionDonut
    return _difference(unionBlind, unionDonut) ?? unionBlind;
  }

  @override
  Widget build(BuildContext context) {
    if (coverageList.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1) Chuyển thành Feature<Polygon> cho blind & detect
    final blindFeatures = <turf.Feature>[];
    final detectFeatures = <turf.Feature>[];

    for (final c in coverageList) {
      if (c.blindCoordinates.length >= 3) {
        blindFeatures.add(_featurePolygonFromCoords(c.blindCoordinates));
      }
      if (c.detectCoordinates.length >= 3) {
        detectFeatures.add(_featurePolygonFromCoords(c.detectCoordinates));
      }
    }

    // 2) detectUnion = union(detect_i)
    final detectUnion = _unionAll(detectFeatures);

    // 3) blindVisible
    final blindVisible = _computeBlindVisible(
      blindPolys: blindFeatures,
      detectPolys: detectFeatures,
    );

    // 4) donut = detectUnion \ blindVisible
    turf.Feature? donutFeat;
    if (detectUnion != null) {
      donutFeat = (blindVisible == null)
          ? detectUnion
          : _difference(detectUnion, blindVisible) ?? detectUnion;
    }

    // ======= Tạo các Layer =======

    final polygons = <Polygon>[];

    // 4.1) Donut (fill + outline)
    if (donutFeat != null) {
      polygons.addAll(
        _geometryToFlutterMapPolygons(
          geometry: donutFeat.geometry,
          fillColor: _detectColor.withOpacity(0.12),
          borderColor: _detectStroke,
          borderStroke: 2.0,
        ),
      );
    }

    // 4.2) blindVisible (fill nhạt + outline) — để hiển thị/ debug "vùng mù"
    if (blindVisible != null) {
      polygons.addAll(
        _geometryToFlutterMapPolygons(
          geometry: blindVisible.geometry,
          fillColor: const Color(0xFF0EA5E9).withOpacity(0.15),
          borderColor: _blindStroke,
          borderStroke: 1.5,
        ),
      );
    }

    // 4.3) Label "{height}m" tại centroid(donut)
    final markers = <Marker>[];
    final labelPos = _centroidLatLng(donutFeat?.geometry);
    if (labelPos != null) {
      markers.add(
        Marker(
          point: labelPos,
          width: 80,
          height: 28,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.white, blurRadius: 2),
              ],
              border: Border.all(color: _blindStroke.withOpacity(0.7)),
            ),
            child: Text(
              '${height.toStringAsFixed(0)}m',
              style: const TextStyle(
                fontSize: 12,
                color: _blindStroke,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // 4.4) (optional) chấm các điểm mẫu
    if (showPoints) {
      for (final c in coverageList) {
        // Blind points (xanh dương nhạt)
        for (final p in c.blindCoordinates) {
          markers.add(
            Marker(
              point: LatLng(p.y, p.x),
              width: 10,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  shape: BoxShape.circle,
                  border: Border.all(color: _blindStroke, width: 1),
                ),
              ),
            ),
          );
        }
        // Detect points (xanh lá)
        for (final p in c.detectCoordinates) {
          markers.add(
            Marker(
              point: LatLng(p.y, p.x),
              width: 10,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: _detectColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: _detectStroke, width: 1),
                ),
              ),
            ),
          );
        }
      }
    }

    return Stack(
      children: [
        if (polygons.isNotEmpty)
          PolygonLayer(
            polygons: polygons,
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: markers,
          ),
      ],
    );
  }
}

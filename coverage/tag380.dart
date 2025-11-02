import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class DonutCoverageLayer extends StatelessWidget {
  final MapController controller;
  final List<List<LatLng>> detectUnionPolygons; // outer rings
  final List<List<LatLng>> blindVisiblePolygons; // holes
  final double height; // m, optional

  const DonutCoverageLayer({
    super.key,
    required this.controller,
    required this.detectUnionPolygons,
    required this.blindVisiblePolygons,
    this.height = 120,
  });

  /// Test xem 1 điểm có nằm trong polygon hay không (Ray casting)
  bool _pointInPolygon(LatLng p, List<LatLng> ring) {
    bool inside = false;
    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i].longitude, yi = ring[i].latitude;
      final xj = ring[j].longitude, yj = ring[j].latitude;
      final intersect = ((yi > p.latitude) != (yj > p.latitude)) &&
          (p.longitude <
              (xj - xi) *
                      (p.latitude - yi) /
                      ((yj - yi) == 0 ? 1e-12 : (yj - yi)) +
                  xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon>[];

    // Với mỗi detect polygon -> tạo PolygonLayer có holes (blind nằm trong)
    for (final outer in detectUnionPolygons) {
      final holesForThisOuter = <List<LatLng>>[];

      for (final hole in blindVisiblePolygons) {
        if (hole.isEmpty) continue;
        if (_pointInPolygon(hole.first, outer)) {
          holesForThisOuter.add(hole);
        }
      }

      polygons.add(
        Polygon(
          points: outer,
          holePointsList: holesForThisOuter, // 👈 fill giữa outer & holes
          color: const Color(0xFF16A34A).withOpacity(0.12),
          borderColor: const Color(0xFF14532D),
          borderStrokeWidth: 2,
          isFilled: true,
        ),
      );
    }

    double angleScreenSpace(MapController controller, LatLng a, LatLng b) {
      final oa = controller.camera.latLngToScreenOffset(a);
      final ob = controller.camera.latLngToScreenOffset(b);
      return math.atan2(ob.dy - oa.dy, ob.dx - oa.dx); // [-pi, pi]
    }

    return Stack(
      children: [
        /// Vẽ vùng donut (detect - blind)
        PolygonLayer(polygons: polygons),

        /// (tuỳ chọn) Vẽ riêng blindVisible nếu muốn thấy viền lỗ
        PolygonLayer(
          polygons: blindVisiblePolygons
              .map(
                (hole) => Polygon(
                  points: hole,
                  isFilled: false,
                  borderColor: const Color(0xFF166534),
                  borderStrokeWidth: 1.5,
                ),
              )
              .toList(),
        ),

        /// (tuỳ chọn) Label độ cao
        MarkerLayer(
          markers: [
            for (final ring in detectLatLngPolygons)
              if (ring.length >= 2)
                Marker(
                  point: ring.first,
                  width: 100,
                  height: 28,
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: angleScreenSpace(controller, ring.first, ring[1]),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(216),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${height.toStringAsFixed(0)}m',
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        )
      ],
    );
  }
}

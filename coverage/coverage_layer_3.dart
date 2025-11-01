import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// rawDetectUnion:  List<List<Map<String, num>>>  // [[{x,y}, ...], ...]
/// rawBlindVisible: List<List<Map<String, num>>>
class DonutWithHolesLayer extends StatelessWidget {
  final MapController controller;
  final List<List<Map<String, num>>> rawDetectUnion;
  final List<List<Map<String, num>>> rawBlindVisible;
  final double height; // nếu muốn vẽ thêm label bằng MarkerLayer

  const DonutWithHolesLayer({
    super.key,
    required this.controller,
    required this.rawDetectUnion,
    required this.rawBlindVisible,
    this.height = 120,
  });

  List<LatLng> _ringToLatLng(List<Map<String, num>> ring) => ring
      .map((p) => LatLng((p['y'] as num).toDouble(), (p['x'] as num).toDouble()))
      .toList();

  /// Ray-casting: test 1 điểm (p) có nằm trong polygon (ring) hay không
  bool _pointInPolygon(LatLng p, List<LatLng> ring) {
    bool inside = false;
    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i].longitude, yi = ring[i].latitude;
      final xj = ring[j].longitude, yj = ring[j].latitude;
      final intersect = ((yi > p.latitude) != (yj > p.latitude)) &&
          (p.longitude <
              (xj - xi) * (p.latitude - yi) / ((yj - yi) == 0 ? 1e-12 : (yj - yi)) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  @override
  Widget build(BuildContext context) {
    // 1) Parse thành List<List<LatLng>>
    final detectPolys = rawDetectUnion.map(_ringToLatLng).toList();
    final blindPolys  = rawBlindVisible.map(_ringToLatLng).toList();

    // 2) Gán blindPoly làm hole của detectPoly nếu blind nằm bên trong detect
    final polygons = <Polygon>[];
    for (final detectRing in detectPolys) {
      // Tìm các hole thuộc về detectRing (dùng điểm đầu của hole để test)
      final holesForThisOuter = <List<LatLng>>[];
      for (final blindRing in blindPolys) {
        if (blindRing.isEmpty) continue;
        if (_pointInPolygon(blindRing.first, detectRing)) {
          holesForThisOuter.add(blindRing);
        }
      }
      polygons.add(
        Polygon(
          points: detectRing,
          holePointsList: holesForThisOuter, // 👈 tạo donut bằng holes
          color: const Color(0xFF16A34A).withOpacity(0.12),
          borderColor: const Color(0xFF14532D),
          borderStrokeWidth: 2,
          isFilled: true,
        ),
      );
    }

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: detectPolys.isNotEmpty && detectPolys.first.isNotEmpty
            ? detectPolys.first.first
            : const LatLng(21.0278, 105.8342),
        initialZoom: 13,
      ),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
        PolygonLayer(polygons: polygons),

        // (tuỳ chọn) nếu muốn vẽ riêng blindVisible (viền) để debug:
        // PolygonLayer(
        //   polygons: blindPolys.map((ring) => Polygon(
        //     points: ring,
        //     isFilled: false,
        //     borderColor: const Color(0xFF166534),
        //     borderStrokeWidth: 1.5,
        //   )).toList(),
        // ),

        // (tuỳ chọn) Marker label độ cao
        // MarkerLayer(
        //   markers: [
        //     for (final ring in detectPolys)
        //       if (ring.isNotEmpty)
        //         Marker(
        //           point: ring[ring.length ~/ 2],
        //           width: 80,
        //           height: 30,
        //           builder: (_) => Container(
        //             alignment: Alignment.center,
        //             decoration: BoxDecoration(
        //               color: Colors.white.withOpacity(0.85),
        //               borderRadius: BorderRadius.circular(6),
        //             ),
        //             child: Text(
        //               '${height.toStringAsFixed(0)}m',
        //               style: const TextStyle(
        //                 color: Color(0xFF166534),
        //                 fontWeight: FontWeight.w600,
        //                 fontSize: 12,
        //               ),
        //             ),
        //           ),
        //         ),
        //   ],
        // ),
      ],
    );
  }
}

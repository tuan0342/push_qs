import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'range_circles_painter.dart';

class RangeCirclesWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng center;

  const RangeCirclesWidget({
    Key? key,
    required this.mapController,
    required this.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true, // Không chặn thao tác với bản đồ
      child: CustomPaint(
        painter: RangeCirclesPainter(
          center: center,
          radiiInKm: [3, 6, 9, 12, 15],
          mapController: mapController,
        ),
        size: Size.infinite,
      ),
    );
  }
}

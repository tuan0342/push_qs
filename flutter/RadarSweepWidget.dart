import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'radar_sweep_painter.dart';

class RadarSweepWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final double startAngleDegrees;

  const RadarSweepWidget({
    super.key,
    required this.mapController,
    required this.center,
    required this.startAngleDegrees,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: RadarSweepPainter(
          center: center,
          mapController: mapController,
          startAngleDegrees: startAngleDegrees,
        ),
        size: Size.infinite,
      ),
    );
  }
}

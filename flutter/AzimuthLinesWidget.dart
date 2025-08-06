import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'azimuth_lines_painter.dart';

class AzimuthLinesWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng center;

  const AzimuthLinesWidget({
    super.key,
    required this.mapController,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: AzimuthLinesPainter(
          center: center,
          mapController: mapController,
        ),
        size: Size.infinite,
      ),
    );
  }
}

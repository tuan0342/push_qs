import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'range_circles_painter.dart';

class RangeCirclesWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final double width;
  final double height;

  const RangeCirclesWidget({
    Key? key,
    required this.center,
    required this.zoom,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: RangeCirclesPainter(
        center: center,
        radiiInKm: [3, 6, 9, 12, 15],
        zoom: zoom,
        width: width,
        height: height,
      ),
    );
  }
}

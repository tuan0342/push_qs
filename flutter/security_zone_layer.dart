// security_zone_layer.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'security_zone_painter.dart';

class SecurityZoneLayer extends StatelessWidget {
  final List<LatLng> points;
  final MapController mapController;

  const SecurityZoneLayer({
    Key? key,
    required this.points,
    required this.mapController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlayImageLayerWidget(
      options: OverlayImageLayerOptions(
        overlayImages: [
          OverlayImage(
            bounds: LatLngBounds.fromPoints(points),
            opacity: 0.0, // invisible background
            imageProvider: const AssetImage(''), // dummy to enable the overlay
          ),
        ],
      ),
      child: CustomPaint(
        painter: SecurityZonePainter(
          points: points,
          mapController: mapController,
        ),
        size: Size.infinite,
      ),
    );
  }
}

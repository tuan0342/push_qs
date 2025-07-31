import 'package:flutter/material.dart';

class CameraControlPanel extends StatelessWidget {
  final void Function()? onShowCameraStream;
  final void Function()? onOpticalScan;
  final void Function()? onTrackObject;
  final void Function()? onTrackNext;

  const CameraControlPanel({
    Key? key,
    this.onShowCameraStream,
    this.onOpticalScan,
    this.onTrackObject,
    this.onTrackNext,
  }) : super(key: key);

  Widget _buildIconButton(IconData icon, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 64,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF2E2E2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Icon(Icons.camera, color: Colors.white),
        Icon(Icons.flash_on, color: Colors.white),
        Icon(Icons.track_changes, color: Colors.white),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xCC1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopButtons(),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildIconButton(Icons.visibility, 'SHOW CAMERA STREAM', onTap: onShowCameraStream),
              _buildIconButton(Icons.center_focus_strong, 'OPTICAL SCAN', onTap: onOpticalScan),
            ],
          ),
          Row(
            children: [
              _buildIconButton(Icons.track_changes, 'TRACK OBJECT', onTap: onTrackObject),
              _buildIconButton(Icons.skip_next, 'TRACK NEXT', onTap: onTrackNext),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'floating_popup.dart';
import 'camera_control_panel.dart';

class TrackPopups extends StatelessWidget {
  final Size trackInfoSize;
  final Size controlPanelSize;
  final VoidCallback onCloseTrackInfo;
  final Widget trackInfoChild;

  const TrackPopups({
    Key? key,
    required this.trackInfoSize,
    required this.controlPanelSize,
    required this.onCloseTrackInfo,
    required this.trackInfoChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Tính toán vị trí hiển thị góc phải
    final double padding = 16;
    final Offset trackInfoPosition = Offset(
      screenSize.width - trackInfoSize.width - padding,
      screenSize.height - trackInfoSize.height - padding,
    );

    final Offset controlPanelPosition = Offset(
      screenSize.width - controlPanelSize.width - padding,
      trackInfoPosition.dy - controlPanelSize.height - 8, // cách 8px phía trên
    );

    return Stack(
      children: [
        // CameraControlPanel ở trên
        FloatingPopup(
          initialPosition: controlPanelPosition,
          initialSize: controlPanelSize,
          onClose: onCloseTrackInfo, // đóng chung với TrackInfo
          showCloseButton: false, // không hiển thị nút đóng
          child: CameraControlPanel(
            onShowCameraStream: () {},
            onOpticalScan: () {},
            onTrackObject: () {},
            onTrackNext: () {},
          ),
        ),

        // TrackInfo ở dưới
        FloatingPopup(
          initialPosition: trackInfoPosition,
          initialSize: trackInfoSize,
          onClose: onCloseTrackInfo, // đóng cả 2 popup
          title: "Track Info",
          showCloseButton: true,
          child: trackInfoChild,
        ),
      ],
    );
  }
}

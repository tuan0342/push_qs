import 'package:flutter/material.dart';

class CameraTabbedPanel extends StatefulWidget {
  const CameraTabbedPanel({super.key});

  @override
  State<CameraTabbedPanel> createState() => _CameraTabbedPanelState();
}

class _CameraTabbedPanelState extends State<CameraTabbedPanel> {
  final List<String> tabs = ['Nhận dạng', 'Phân loại', 'Chế áp', 'Bắn', 'Video'];
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    const Color tabInactiveColor = Color(0xFF424240); // Màu nền tab chưa chọn
    const Color tabTextColor = Colors.white70;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xDD1E1E1E), // Nền trong suốt nhẹ
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh Tab scroll ngang
          // Thanh Tab scroll ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (index) {
                final bool isSelected = index == selectedTabIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTabIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.transparent : tabInactiveColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      height: 40,
                      child: Text(
                        tabs[index],
                        style: const TextStyle(
                          color: tabTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),


          const SizedBox(height: 12),

          // Nội dung scroll dọc của tab
          Expanded(
            child: SingleChildScrollView(
              child: _buildTabContent(tabs[selectedTabIndex]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String tab) {
    const Color contentColor = Color(0xFFB0B0B0); // Màu giống với label trong ảnh
    TextStyle labelStyle = const TextStyle(color: contentColor, fontSize: 14);

    switch (tab) {
      case 'Nhận dạng':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _button('SHOW CAMERA STREAM', Icons.visibility),
            _button('OPTICAL SCAN', Icons.center_focus_strong),
            _button('TRACK OBJECT', Icons.track_changes),
            _button('TRACK NEXT', Icons.skip_next),
          ],
        );
      case 'Phân loại':
        return Column(
          children: [
            _button('CLASSIFY VEHICLE', Icons.car_rental),
            _button('CLASSIFY PERSON', Icons.person),
          ],
        );
      case 'Chế áp':
        return Column(
          children: [
            _button('JAM TARGET', Icons.wifi_off),
            _button('DISABLE SENSORS', Icons.sensors_off),
          ],
        );
      case 'Bắn':
        return Column(
          children: [
            _button('ARM WEAPON', Icons.security),
            _button('FIRE', Icons.bolt),
          ],
        );
      case 'Video':
        return Column(
          children: [
            _button('RECORD', Icons.fiber_manual_record),
            _button('SNAPSHOT', Icons.camera_alt),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _button(String label, IconData icon) {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

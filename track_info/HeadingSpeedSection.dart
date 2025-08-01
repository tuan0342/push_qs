class HeadingSpeedSection extends StatelessWidget {
  const HeadingSpeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _sectionBox(
      title: 'HEADING & SPEED',
      children: [
        const SizedBox(height: 8),
        const SpeedCircle(heading: 214, speed: 1600),
        const SizedBox(height: 8),
        const Text(
          'DURATION',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const Text(
          '34:15',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _AltitudeItem(label: 'CURRENT ALT', value: '102.8'),
            _AltitudeItem(label: 'MAX ALT', value: '328.08'),
          ],
        ),
      ],
    );
  }
}

class _AltitudeItem extends StatelessWidget {
  final String label;
  final String value;

  const _AltitudeItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 4),
            const Text('KFT', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class SpeedCircle extends StatelessWidget {
  final int heading;
  final int speed;

  const SpeedCircle({super.key, required this.heading, required this.speed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(100, 100),
            painter: _HalfCirclePainter(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  '$heading°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$speed.0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'm/s',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HalfCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint topPaint = Paint()..color = Colors.black;
    final Paint bottomPaint = Paint()..color = Colors.red.shade700;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Vẽ nửa trên (đen)
    canvas.drawArc(rect, -pi, pi, false, topPaint);

    // Vẽ nửa dưới (đỏ)
    canvas.drawArc(rect, 0, pi, false, bottomPaint);

    // Viền ngoài
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

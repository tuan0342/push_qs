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

class SpeedCircle extends StatelessWidget {
  final int heading;
  final int speed;

  const SpeedCircle({super.key, required this.heading, required this.speed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.black, Colors.redAccent],
          center: Alignment.bottomCenter,
          radius: 0.9,
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$heading°',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            '$speed.0',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Text(
            'm/s',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
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


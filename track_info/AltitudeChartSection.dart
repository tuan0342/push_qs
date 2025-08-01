class AltitudeChartSection extends StatelessWidget {
  const AltitudeChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> altitudeData = List.generate(
      20,
      (index) => FlSpot(index.toDouble(), 250 + 50 * (index % 4 - 1)), // Giả lập dao động độ cao
    );

    return _sectionBox(
      title: 'ALTITUDE CHART',
      children: [
        Container(
          height: 120,
          padding: const EdgeInsets.only(top: 8, right: 12),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) =>
                        Text('${value.toInt()}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) =>
                        Text('${value.toInt()}K', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: altitudeData,
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white30)),
              minX: 0,
              maxX: 19,
              minY: 100,
              maxY: 400,
            ),
          ),
        ),
      ],
    );
  }
}

const _infoStyle = TextStyle(color: Colors.white70, fontSize: 14);

Widget _sectionBox({required String title, required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      border: Border.all(color: Colors.white30),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );
}

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton(onPressed: () {}, child: const Text('Activate Critical')),
        const SizedBox(width: 12),
        FilledButton(onPressed: () {}, child: const Text('Weapon Safe')),
        const SizedBox(width: 12),
        FilledButton(onPressed: () {}, child: const Text('Engage')),
      ],
    );
  }
}

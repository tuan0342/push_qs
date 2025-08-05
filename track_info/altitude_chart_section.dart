class AltitudeChartSection extends StatelessWidget {
  const AltitudeChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả cho độ cao (theo giây)
    final List<FlSpot> altitudeData = List.generate(
      20,
      (index) => FlSpot(index.toDouble(), 250 + 50 * (index % 4 - 1)),
    );

    // Dữ liệu giả cho vận tốc (theo phút)
    final List<FlSpot> speedData = List.generate(
      10,
      (index) => FlSpot(index.toDouble(), 1200 + 100 * (index % 3 - 1)),
    );

    return _sectionBox(
      title: 'ALTITUDE & SPEED CHART',
      children: [
        // Biểu đồ độ cao
        _chartContainer(
          title: 'Altitude (KFT)',
          data: altitudeData,
          yUnit: 'KFT',
          xUnit: 's',
          yMin: 100,
          yMax: 400,
          xMin: 0,
          xMax: 19,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 12),
        // Biểu đồ vận tốc
        _chartContainer(
          title: 'Speed (m/s)',
          data: speedData,
          yUnit: 'm/s',
          xUnit: 'min',
          yMin: 1000,
          yMax: 1600,
          xMin: 0,
          xMax: 9,
          color: Colors.cyanAccent,
        ),
      ],
    );
  }

  Widget _chartContainer({
    required String title,
    required List<FlSpot> data,
    required String yUnit,
    required String xUnit,
    required double yMin,
    required double yMax,
    required double xMin,
    required double xMax,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) => SizedBox(
                      width: 30,
                      child: Text('${value.toInt()}$xUnit',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                        style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white30)),
              minX: xMin,
              maxX: xMax,
              minY: yMin,
              maxY: yMax,
            ),
          ),
        ),
      ],
    );
  }
}

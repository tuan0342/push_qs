/// Tính trục Y "đẹp": minY, maxY, interval
class NiceAxis {
  final double minY;
  final double maxY;
  final double interval;
  NiceAxis(this.minY, this.maxY, this.interval);
}

NiceAxis makeNiceAxis({
  required double dataMin,
  required double dataMax,
  int targetTickCount = 5, // 5–6 là dễ nhìn
}) {
  // đảm bảo range dương
  final safeMin = dataMin.isFinite ? dataMin : 0.0;
  final safeMax = dataMax.isFinite ? dataMax : 1.0;
  final rangeRaw = (safeMax - safeMin).abs() < 1e-12 ? 1.0 : (safeMax - safeMin);

  // ước lượng bước
  final roughStep = rangeRaw / (targetTickCount - 1);
  // chuẩn hoá bước về 1–2–5×10^k
  double niceStep() {
    final pow10 = (log(roughStep) / log(10)).floorToDouble();
    final base = pow(10.0, pow10);
    final unit = roughStep / base; // trong khoảng ~[1,10)
    if (unit <= 1.0) return 1.0 * base;
    if (unit <= 2.0) return 2.0 * base;
    if (unit <= 5.0) return 5.0 * base;
    return 10.0 * base;
  }

  final step = niceStep();

  // làm tròn min/max theo step
  final minNice = (safeMin / step).floorToDouble() * step;
  final maxNice = (safeMax / step).ceilToDouble() * step;

  return NiceAxis(minNice, maxNice, step);
}

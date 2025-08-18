import 'package:flutter/material.dart';

class DMSValue {
  final int deg;
  final int min;
  final int sec;

  const DMSValue(this.deg, this.min, this.sec);

  double toDecimal() => deg + min / 60 + sec / 3600;

  static DMSValue fromDecimal(double decimal) {
    final degrees = decimal.floor();
    final minutesFull = (decimal - degrees) * 60;
    final minutes = minutesFull.floor();
    final seconds = ((minutesFull - minutes) * 60).round();
    return DMSValue(degrees, minutes, seconds);
  }
}

class LatLngDMSInput extends StatefulWidget {
  final String label;
  final DMSValue value;
  final ValueChanged<DMSValue> onChanged;
  final bool isLongitude;
  final String? errorText;

  const LatLngDMSInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isLongitude,
    this.errorText,
  });

  @override
  State<LatLngDMSInput> createState() => _LatLngDMSInputState();
}

class _LatLngDMSInputState extends State<LatLngDMSInput> {
  late final TextEditingController degCtrl;
  late final TextEditingController minCtrl;
  late final TextEditingController secCtrl;

  int deg = 0;
  int min = 0;
  int sec = 0;

  @override
  void initState() {
    super.initState();
    deg = widget.value.deg;
    min = widget.value.min;
    sec = widget.value.sec;

    degCtrl = TextEditingController(text: deg.toString());
    minCtrl = TextEditingController(text: min.toString());
    secCtrl = TextEditingController(text: sec.toString());
  }

  @override
  void didUpdateWidget(covariant LatLngDMSInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync if external value changed
    if (widget.value != oldWidget.value) {
      deg = widget.value.deg;
      min = widget.value.min;
      sec = widget.value.sec;
      degCtrl.text = deg.toString();
      minCtrl.text = min.toString();
      secCtrl.text = sec.toString();
    }
  }

  void _normalizeAndUpdate() {
    int newDeg = deg;
    int newMin = min;
    int newSec = sec;

    if (newSec >= 60) {
      newMin += newSec ~/ 60;
      newSec %= 60;
    }

    if (newMin >= 60) {
      newDeg += newMin ~/ 60;
      newMin %= 60;
    }

    setState(() {
      deg = newDeg;
      min = newMin;
      sec = newSec;

      degCtrl.text = deg.toString();
      minCtrl.text = min.toString();
      secCtrl.text = sec.toString();
    });

    widget.onChanged(DMSValue(deg, min, sec));
  }

  void _onDegChanged(String text) {
    deg = int.tryParse(text) ?? 0;
    _normalizeAndUpdate();
  }

  void _onMinChanged(String text) {
    min = int.tryParse(text) ?? 0;
    _normalizeAndUpdate();
  }

  void _onSecChanged(String text) {
    sec = int.tryParse(text) ?? 0;
    _normalizeAndUpdate();
  }

  @override
  void dispose() {
    degCtrl.dispose();
    minCtrl.dispose();
    secCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildField(degCtrl, '°', _onDegChanged, flex: 3),
            const SizedBox(width: 8),
            _buildField(minCtrl, '\'', _onMinChanged, flex: 2),
            const SizedBox(width: 8),
            _buildField(secCtrl, '"', _onSecChanged, flex: 2),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(widget.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String suffix,
      ValueChanged<String> onChanged,
      {required int flex}) {
    return Expanded(
      flex: flex,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          suffixText: suffix,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    degCtrl = TextEditingController();
    minCtrl = TextEditingController();
    secCtrl = TextEditingController();
    _syncWithValue(widget.value);
  }

  @override
  void didUpdateWidget(covariant LatLngDMSInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync if new value is different and not currently editing
    if (!_isEditing() && widget.value != oldWidget.value) {
      _syncWithValue(widget.value);
    }
  }

  void _syncWithValue(DMSValue value) {
    degCtrl.text = value.deg.toString();
    minCtrl.text = value.min.toString();
    secCtrl.text = value.sec.toString();
  }

  bool _isEditing() {
    return degCtrl.selection.baseOffset != -1 ||
        minCtrl.selection.baseOffset != -1 ||
        secCtrl.selection.baseOffset != -1;
  }

  void _handleChange() {
    int deg = int.tryParse(degCtrl.text) ?? 0;
    int min = int.tryParse(minCtrl.text) ?? 0;
    int sec = int.tryParse(secCtrl.text) ?? 0;

    if (sec >= 60) {
      min += sec ~/ 60;
      sec %= 60;
    }
    if (min >= 60) {
      deg += min ~/ 60;
      min %= 60;
    }

    widget.onChanged(DMSValue(deg, min, sec));
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
            _buildField(degCtrl, '°'),
            const SizedBox(width: 8),
            _buildField(minCtrl, "'"),
            const SizedBox(width: 8),
            _buildField(secCtrl, '"'),
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

  Widget _buildField(TextEditingController controller, String suffix) {
    return Expanded(
      flex: suffix == '°' ? 3 : 2,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => _handleChange(),
        decoration: InputDecoration(
          suffixText: suffix,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }
}

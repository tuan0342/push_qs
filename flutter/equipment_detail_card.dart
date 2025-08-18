class ReactiveLatLngField extends StatefulWidget {
  final String formControlName;
  final String label;
  final bool isLongitude;

  const ReactiveLatLngField({
    super.key,
    required this.formControlName,
    required this.label,
    required this.isLongitude,
  });

  @override
  State<ReactiveLatLngField> createState() => _ReactiveLatLngFieldState();
}

class _ReactiveLatLngFieldState extends State<ReactiveLatLngField> {
  late final TextEditingController degCtrl;
  late final TextEditingController minCtrl;
  late final TextEditingController secCtrl;

  @override
  void initState() {
    super.initState();
    degCtrl = TextEditingController();
    minCtrl = TextEditingController();
    secCtrl = TextEditingController();
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
    return ReactiveFormField<double, double>(
      formControlName: widget.formControlName,
      validationMessages: (control) => {
        ValidationMessage.min: widget.isLongitude
            ? 'Kinh độ phải nằm trong khoảng 97 - 117'
            : 'Vĩ độ phải nằm trong khoảng 5 - 30',
        ValidationMessage.max: widget.isLongitude
            ? 'Kinh độ phải nằm trong khoảng 97 - 117'
            : 'Vĩ độ phải nằm trong khoảng 5 - 30',
      },
      builder: (field) {
        // Chỉ gán giá trị nếu field.value thay đổi
        if (field.value != null) {
          final dms = _decimalToDMS(field.value!);
          if (!_isEditing()) {
            degCtrl.text = dms[0].toString();
            minCtrl.text = dms[1].toString();
            secCtrl.text = dms[2].toString();
          }
        }

        void onChanged() {
          int deg = int.tryParse(degCtrl.text) ?? 0;
          int min = int.tryParse(minCtrl.text) ?? 0;
          int sec = int.tryParse(secCtrl.text) ?? 0;

          // Convert overflow
          if (sec >= 60) {
            min += sec ~/ 60;
            sec = sec % 60;
          }

          if (min >= 60) {
            deg += min ~/ 60;
            min = min % 60;
          }

          double decimal = deg + min / 60 + sec / 3600;
          field.didChange(decimal);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildIntField(degCtrl, '°', onChanged, flex: 3),
                const SizedBox(width: 8),
                _buildIntField(minCtrl, '\'', onChanged, flex: 2),
                const SizedBox(width: 8),
                _buildIntField(secCtrl, '"', onChanged, flex: 2),
              ],
            ),
            if (field.control.invalid && field.control.touched)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  field.errorText ?? '',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildIntField(TextEditingController ctrl, String suffix,
      VoidCallback onChanged, {required int flex}) {
    return Expanded(
      flex: flex,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          suffixText: suffix,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }

  List<int> _decimalToDMS(double value) {
    int degrees = value.floor();
    double fractional = value - degrees;
    int minutes = (fractional * 60).floor();
    int seconds = ((fractional * 60 - minutes) * 60).round();
    return [degrees, minutes, seconds];
  }

  bool _isEditing() {
    // Kiểm tra nếu người dùng đang gõ để không override text
    return FocusScope.of(context).hasFocus;
  }
}

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveLatLngField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ReactiveFormField<double, double>(
      formControlName: formControlName,
      validationMessages: (control) => {
        ValidationMessage.min: isLongitude
            ? 'Kinh độ phải nằm trong khoảng 97 - 117'
            : 'Vĩ độ phải nằm trong khoảng 5 - 30',
        ValidationMessage.max: isLongitude
            ? 'Kinh độ phải nằm trong khoảng 97 - 117'
            : 'Vĩ độ phải nằm trong khoảng 5 - 30',
      },
      builder: (field) {
        final value = field.value ?? 0;
        final dms = _decimalToDMS(value);

        final degCtrl = TextEditingController(text: dms[0].toString());
        final minCtrl = TextEditingController(text: dms[1].toString());
        final secCtrl = TextEditingController(text: dms[2].toString());

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

          // Update the UI controllers after conversion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            degCtrl.text = deg.toString();
            minCtrl.text = min.toString();
            secCtrl.text = sec.toString();
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.labelLarge),
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
      VoidCallback onChanged,
      {required int flex}) {
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

  /// Convert from decimal to [degrees, minutes, seconds]
  List<int> _decimalToDMS(double value) {
    int degrees = value.floor();
    double fractional = value - degrees;
    int minutes = (fractional * 60).floor();
    int seconds = ((fractional * 60 - minutes) * 60).round();
    return [degrees, minutes, seconds];
  }
}

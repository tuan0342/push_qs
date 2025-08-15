import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveLatLngField extends ReactiveFormField<double, double> {
  ReactiveLatLngField({
    super.key,
    required String formControlName,
    required String label,
  }) : super(
          formControlName: formControlName,
          builder: (field) {
            final double value = field.value ?? 0;
            final dms = _decimalToDMS(value);

            final degreesCtrl = TextEditingController(text: dms.degrees.toString());
            final minutesCtrl = TextEditingController(text: dms.minutes.toString());
            final secondsCtrl = TextEditingController(text: dms.seconds.toString());

            void updateValue() {
              final deg = int.tryParse(degreesCtrl.text) ?? 0;
              final min = int.tryParse(minutesCtrl.text) ?? 0;
              final sec = double.tryParse(secondsCtrl.text) ?? 0;
              final decimal = _dmsToDecimal(deg, min, sec);
              field.didChange(decimal);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70)),
                Row(
                  children: [
                    _dmsInput(degreesCtrl, '°', onChanged: updateValue),
                    const SizedBox(width: 8),
                    _dmsInput(minutesCtrl, '\'', onChanged: updateValue),
                    const SizedBox(width: 8),
                    _dmsInput(secondsCtrl, '"', onChanged: updateValue),
                  ],
                ),
                if (field.hasError)
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

  @override
  ReactiveFormFieldState<double, double> createState() =>
      ReactiveFormFieldState<double, double>();
}
Widget _dmsInput(TextEditingController ctrl, String suffix, {required VoidCallback onChanged}) {
  return SizedBox(
    width: 70,
    child: TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        suffixText: suffix,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => onChanged(),
    ),
  );
}

class DMS {
  final int degrees;
  final int minutes;
  final double seconds;

  DMS(this.degrees, this.minutes, this.seconds);
}

DMS _decimalToDMS(double decimal) {
  final degrees = decimal.truncate();
  final minutesDecimal = (decimal - degrees) * 60;
  final minutes = minutesDecimal.truncate();
  final seconds = (minutesDecimal - minutes) * 60;
  return DMS(degrees, minutes, seconds);
}

double _dmsToDecimal(int degrees, int minutes, double seconds) {
  return degrees + minutes / 60 + seconds / 3600;
}

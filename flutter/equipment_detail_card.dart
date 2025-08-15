import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveLatLngField extends ReactiveFormField<double, double> {
  ReactiveLatLngField({
    super.key,
    required String formControlName,
    required String label,
    required bool isLongitude, // true: long, false: lat
  }) : super(
          formControlName: formControlName,
          validationMessages: (control) => {
            'outOfRange': isLongitude
                ? 'Kinh độ phải nằm trong khoảng 97 - 117'
                : 'Vĩ độ phải nằm trong khoảng 5 - 30',
          },
          builder: (field) {
            final double value = field.value ?? 0;
            final dms = _decimalToDMS(value);

            final degCtrl = TextEditingController(text: dms.degrees.toString());
            final minCtrl = TextEditingController(text: dms.minutes.toString());
            final secCtrl = TextEditingController(text: dms.seconds.toStringAsFixed(2));

            void updateValue() {
              final deg = int.tryParse(degCtrl.text) ?? 0;
              final min = int.tryParse(minCtrl.text) ?? 0;
              final sec = double.tryParse(secCtrl.text) ?? 0.0;

              final decimal = _dmsToDecimal(deg, min, sec);
              field.didChange(decimal);

              // Validate range
              if (isLongitude && (decimal < 97 || decimal > 117)) {
                field.control.setErrors({'outOfRange': true});
              } else if (!isLongitude && (decimal < 5 || decimal > 30)) {
                field.control.setErrors({'outOfRange': true});
              } else {
                field.control.removeError('outOfRange');
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _dmsInput(degCtrl, '°', onChanged: updateValue),
                    const SizedBox(width: 6),
                    _dmsInput(minCtrl, '\'', onChanged: updateValue),
                    const SizedBox(width: 6),
                    _dmsInput(secCtrl, '"', onChanged: updateValue),
                  ],
                ),
                if (field.control.invalid && field.control.touched)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      field.control.errors.values.first.toString(),
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

Widget _dmsInput(TextEditingController ctrl, String suffix, {required VoidCallback onChanged}) {
  return SizedBox(
    width: 72,
    child: TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => onChanged(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveLatLngField extends ReactiveFormField<double, DMSValue> {
  ReactiveLatLngField({
    super.key,
    required String formControlName,
    required String label,
    required bool isLongitude,
  }) : super(
          formControlName: formControlName,
          valueAccessor: LatLngValueAccessor(),
          validationMessages: (control) => {
            ValidationMessage.min: isLongitude
                ? 'Kinh độ phải nằm trong khoảng 97 - 117'
                : 'Vĩ độ phải nằm trong khoảng 5 - 30',
            ValidationMessage.max: isLongitude
                ? 'Kinh độ phải nằm trong khoảng 97 - 117'
                : 'Vĩ độ phải nằm trong khoảng 5 - 30',
          },
          builder: (field) {
            final value = field.value ?? const DMSValue(0, 0, 0);
            return LatLngDMSInput(
              label: label,
              value: value,
              onChanged: field.didChange,
              isLongitude: isLongitude,
              errorText: field.errorText,
            );
          },
        );
}

import 'package:flutter/material.dart';

class LatLngDMSInput extends StatelessWidget {
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

  void _handleChange(BuildContext context, String degText, String minText, String secText) {
    int deg = int.tryParse(degText) ?? 0;
    int min = int.tryParse(minText) ?? 0;
    int sec = int.tryParse(secText) ?? 0;

    // Convert overflow
    if (sec >= 60) {
      min += sec ~/ 60;
      sec %= 60;
    }
    if (min >= 60) {
      deg += min ~/ 60;
      min %= 60;
    }

    onChanged(DMSValue(deg, min, sec));
  }

  @override
  Widget build(BuildContext context) {
    final degCtrl = TextEditingController(text: value.deg.toString());
    final minCtrl = TextEditingController(text: value.min.toString());
    final secCtrl = TextEditingController(text: value.sec.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildField(context, degCtrl, '°', (v) => _handleChange(context, v, minCtrl.text, secCtrl.text), flex: 3),
            const SizedBox(width: 8),
            _buildField(context, minCtrl, '\'', (v) => _handleChange(context, degCtrl.text, v, secCtrl.text), flex: 2),
            const SizedBox(width: 8),
            _buildField(context, secCtrl, '"', (v) => _handleChange(context, degCtrl.text, minCtrl.text, v), flex: 2),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildField(BuildContext context, TextEditingController controller, String suffix,
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

import 'package:reactive_forms/reactive_forms.dart';

class LatLngValueAccessor extends ControlValueAccessor<double, DMSValue> {
  @override
  DMSValue? modelToViewValue(double? modelValue) {
    if (modelValue == null) return const DMSValue(0, 0, 0);
    return DMSValue.fromDecimal(modelValue);
  }

  @override
  double? viewToModelValue(DMSValue? viewValue) {
    return viewValue?.toDecimal();
  }
}

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

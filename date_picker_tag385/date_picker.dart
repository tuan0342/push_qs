import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';

// intl: ^0.19.0

class DatePickerPage extends StatefulWidget {
  const DatePickerPage({super.key});

  @override
  State<DatePickerPage> createState() => _DatePickerPageState();
}

class _DatePickerPageState extends State<DatePickerPage> {
  final form = FormGroup({
    'selectedDate': FormControl<DateTime>(),
    'name': FormControl<String>(),
  });

  @override
  void initState() {
    super.initState();

    // Chuẩn hoá về 00:00 cùng ngày khi người dùng chọn
    form.control('selectedDate').valueChanges.listen((date) {
      if (date != null) {
        final normalized = DateTime(date.year, date.month, date.day);
        form
            .control('selectedDate')
            .updateValue(normalized, updateParent: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Colors.grey.shade400),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reactive DatePicker Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Tên',
                formControlName: 'name',
                border: border,
                hintText: 'Nhập tên',
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Ngày',
                formControlName: 'selectedDate',
                border: border,
                hintText: 'Chọn ngày',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Tên',
                      formControlName: 'name',
                      border: border,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Ngày',
                      formControlName: 'name',
                      border: border,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Giờ',
                      formControlName: 'name',
                      border: border,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              ReactiveFormConsumer(
                builder: (context, form, child) {
                  final date = form.control('selectedDate').value as DateTime?;
                  return Text(
                    date == null
                        ? 'No date selected'
                        : 'Timestamp: ${date.millisecondsSinceEpoch}',
                    style: const TextStyle(fontSize: 16),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (form.valid) {
                    final selected =
                        form.control('selectedDate').value as DateTime?;
                    if (selected != null) {
                      final ts = selected.millisecondsSinceEpoch;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Submitted timestamp: $ts (${selected.toLocal()})',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelInputRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  /// --- Input text field có label ---
  Widget _buildTextField({
    required String label,
    required String formControlName,
    required OutlineInputBorder border,
    String hintText = '',
  }) {
    return _buildLabelInputRow(
      label: label,
      child: ReactiveTextField<String>(
        formControlName: formControlName,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  /// --- Date picker field có label ---
  Widget _buildDateField({
    required String label,
    required String formControlName,
    required OutlineInputBorder border,
    String hintText = '',
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    firstDate ??= DateTime(2020);
    lastDate ??= DateTime(2030);

    return _buildLabelInputRow(
      label: label,
      child: ReactiveDatePicker<DateTime>(
        formControlName: formControlName,
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (context, picker, child) {
          final dateText =
              picker.value == null
                  ? hintText
                  : DateFormat('dd/MM/yyyy').format(picker.value!.toLocal());
          return InkWell(
            onTap: picker.showPicker,
            borderRadius: BorderRadius.circular(6),
            child: InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: border,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          picker.value == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                    ),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

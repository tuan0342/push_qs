class AreaFormCard extends StatefulWidget {
  const AreaFormCard({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.initial,
  });

  final AreaObject? initial;
  final void Function(AreaObject area) onSubmit;
  final VoidCallback onCancel;

  @override
  State<AreaFormCard> createState() => _AreaFormCardState();
}

class _AreaFormCardState extends State<AreaFormCard> {
  late final AreaDtoForm _form; // generated typed form extends FormGroup

  FormArray<LatLngDtoForm> get _pointsArray => _form.points;

  @override
  void initState() {
    super.initState();
    _form = _buildGeneratedForm(widget.initial);
  }

  AreaDtoForm _buildGeneratedForm(AreaObject? initial) {
    final AreaDto dto = initial == null
        ? AreaDto(
            id: '',
            name: '',
            points: [const LatLngDto(latitude: null, longitude: null)],
          )
        : AreaDto(
            id: initial.id,
            name: initial.name,
            points: initial.points
                .map((p) => LatLngDto(latitude: p.latitude, longitude: p.longitude))
                .toList(),
          );

    return AreaDtoForm(dto);
  }

  void _addPoint() => _pointsArray.add(const LatLngDtoForm(LatLngDto(latitude: null, longitude: null)));

  void _removePoint(int index) {
    if (_pointsArray.controls.length > 1) {
      _pointsArray.removeAt(index);
    }
  }

  void _submit() {
    if (!_form.valid) {
      _form.markAllAsTouched();
      return;
    }

    // Safely read from typed controls (avoid relying on generator-specific model getters)
    final id = _form.id.value ?? '';
    final name = _form.name.value ?? '';

    final pts = _pointsArray.controls.map((c) {
      final pt = c as LatLngDtoForm;
      final lat = pt.latitude.value!;
      final lng = pt.longitude.value!;
      return LatLng(lat, lng);
    }).toList();

    widget.onSubmit(AreaObject(id: id, name: name, points: pts));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ReactiveForm(
          formGroup: _form, // generated form is a FormGroup
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tạo/Sửa vùng', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              // ID
              ReactiveTextField<String>(
                formControl: _form.id,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Bắt buộc',
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Name
              ReactiveTextField<String>(
                formControl: _form.name,
                decoration: const InputDecoration(
                  labelText: 'Tên vùng',
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Bắt buộc',
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Points header + add
              Row(
                children: [
                  Expanded(
                    child: Text('Danh sách điểm (lat/lng)',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  IconButton(
                    tooltip: 'Thêm điểm',
                    onPressed: _addPoint,
                    icon: const Icon(Icons.add_location_alt_outlined),
                  ),
                ],
              ),

              // Points list from generated FormArray<LatLngDtoForm>
              Column(
                children: [
                  for (int i = 0; i < _pointsArray.controls.length; i++)
                    _GeneratedPointFields(
                      index: i,
                      pointForm: _pointsArray.controls[i] as LatLngDtoForm,
                      onRemove: () => _removePoint(i),
                      canRemove: _pointsArray.controls.length > 1,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: widget.onCancel, child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Lưu vùng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// Generated point row fields wrapper (uses LatLngDtoForm)
// =====================
class _GeneratedPointFields extends StatelessWidget {
  const _GeneratedPointFields({
    required this.index,
    required this.pointForm,
    required this.onRemove,
    required this.canRemove,
  });

  final int index;
  final LatLngDtoForm pointForm; // generated FormGroup for LatLngDto
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ReactiveTextField<double>(
              formControl: pointForm.latitude,
              valueAccessor: const _DoubleAccessor(),
              decoration: InputDecoration(
                labelText: 'Latitude [điểm ${index + 1}]',
                border: const OutlineInputBorder(),
              ),
              validationMessages: {
                ValidationMessage.required: (_) => 'Bắt buộc',
                ValidationMessage.min: (_) => '>= -90',
                ValidationMessage.max: (_) => '<= 90',
              },
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ReactiveTextField<double>(
              formControl: pointForm.longitude,
              valueAccessor: const _DoubleAccessor(),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              validationMessages: {
                ValidationMessage.required: (_) => 'Bắt buộc',
                ValidationMessage.min: (_) => '>= -180',
                ValidationMessage.max: (_) => '<= 180',
              },
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: canRemove ? 'Xóa điểm' : 'Cần ít nhất 1 điểm',
            onPressed: canRemove ? onRemove : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}

// =====================
// Helper: parse double from text for ReactiveTextField<double>
// =====================
class _DoubleAccessor extends ControlValueAccessor<double, String> {
  const _DoubleAccessor();

  @override
  String? modelToViewValue(double? modelValue) {
    if (modelValue == null) return null;
    return modelValue.toString();
  }

  @override
  double? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.trim().isEmpty) return null;
    return double.tryParse(viewValue.replaceAll(',', '.'));
  }
}

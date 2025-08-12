Future<void> _openEditDialog(BuildContext context) async {
    final updated = await showEditMyObjectDialog(context, widget.obj);
    if (updated != null && mounted) {
      widget.onEdit?.call(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Xóa mục này?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn sắp xóa “${widget.obj.name}”. Hành động này không thể hoàn tác.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB00020),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      widget.onDelete?.call(widget.obj.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa')),
      );
    }
  }

  Future<MyObject?> showEditMyObjectDialog(BuildContext context, MyObject obj) async {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController(text: obj.name);
  final ipCtrl = TextEditingController(text: obj.ip);
  final latCtrl = TextEditingController(text: obj.lat.toString());
  final longCtrl = TextEditingController(text: obj.long.toString());
  ObjectType typeVal = obj.type;

  return showDialog<MyObject?>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color.fromRGBO(31, 31, 31, 0.92),
      title: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                label: 'Name',
                controller: nameCtrl,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 10),
              _field(
                label: 'IP',
                controller: ipCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                  // validate ip đơn giản
                  final parts = v.split('.');
                  if (parts.length != 4) return 'IP không hợp lệ';
                  try {
                    if (parts.any((p) {
                      final n = int.parse(p);
                      return n < 0 || n > 255;
                    })) return 'IP không hợp lệ';
                  } catch (_) {
                    return 'IP không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _numberField(label: 'Lat', controller: latCtrl),
              const SizedBox(height: 10),
              _numberField(label: 'Long', controller: longCtrl),
              const SizedBox(height: 10),
              _typeDropdown(
                value: typeVal,
                onChanged: (v) {
                  if (v != null) {
                    typeVal = v;
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final updated = MyObject(
                id: obj.id,
                name: nameCtrl.text.trim(),
                ip: ipCtrl.text.trim(),
                lat: double.tryParse(latCtrl.text.trim()) ?? obj.lat,
                long: double.tryParse(longCtrl.text.trim()) ?? obj.long,
                type: typeVal,
              );
              Navigator.pop(context, updated);
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}

Widget _field({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.35)),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget _numberField({
  required String label,
  required TextEditingController controller,
}) {
  return _field(
    label: label,
    controller: controller,
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Bắt buộc';
      final d = double.tryParse(v.trim());
      if (d == null) return 'Phải là số';
      return null;
    },
  );
}

Widget _typeDropdown({
  required ObjectType value,
  required ValueChanged<ObjectType?> onChanged,
}) {
  return DropdownButtonFormField<ObjectType>(
    value: value,
    onChanged: onChanged,
    dropdownColor: const Color(0xFF2A2A2A),
    items: ObjectType.values
        .map((t) => DropdownMenuItem(
              value: t,
              child: Text(t.name, style: const TextStyle(color: Colors.white)),
            ))
        .toList(),
    decoration: InputDecoration(
      labelText: 'Type',
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.35)),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    style: const TextStyle(color: Colors.white),
  );
}

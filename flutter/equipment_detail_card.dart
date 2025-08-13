Future<MyObject?> showCreateMyObjectDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final ipCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final longCtrl = TextEditingController();
  ObjectType typeVal = ObjectType.UUUU;

  return showDialog<MyObject?>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color.fromRGBO(31, 31, 31, 0.92),
      title: const Text('Thêm thiết bị', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(label: 'Name', controller: nameCtrl, validator: _required),
              const SizedBox(height: 10),
              _field(label: 'IP', controller: ipCtrl, validator: _ipValidator),
              const SizedBox(height: 10),
              _numberField(label: 'Lat', controller: latCtrl),
              const SizedBox(height: 10),
              _numberField(label: 'Long', controller: longCtrl),
              const SizedBox(height: 10),
              _typeDropdown(
                value: typeVal,
                onChanged: (v) {
                  if (v != null) typeVal = v;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final obj = MyObject(
                id: '', // sẽ bỏ qua khi POST
                name: nameCtrl.text.trim(),
                ip: ipCtrl.text.trim(),
                lat: double.tryParse(latCtrl.text.trim()) ?? 0,
                long: double.tryParse(longCtrl.text.trim()) ?? 0,
                type: typeVal,
              );
              Navigator.pop(context, obj);
            }
          },
          child: const Text('Tạo'),
        ),
      ],
    ),
  );
}

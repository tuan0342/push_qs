class GridSizeDialog extends StatefulWidget {
  final int rows;
  final int columns;

  const GridSizeDialog({super.key, required this.rows, required this.columns});

  @override
  State<GridSizeDialog> createState() => _GridSizeDialogState();
}

class _GridSizeDialogState extends State<GridSizeDialog> {
  late int rows;
  late int columns;

  @override
  void initState() {
    super.initState();
    rows = widget.rows;
    columns = widget.columns;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh lưới video'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dòng: $rows'),
          Slider(
            value: rows.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '$rows',
            onChanged: (val) => setState(() => rows = val.toInt()),
          ),
          Text('Cột: $columns'),
          Slider(
            value: columns.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '$columns',
            onChanged: (val) => setState(() => columns = val.toInt()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, (rows, columns)),
          child: const Text('Xong'),
        ),
      ],
    );
  }
}

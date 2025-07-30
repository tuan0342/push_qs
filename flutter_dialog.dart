import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClose;
  final VoidCallback? onConfirm;
  final String title;
  final Offset initialPosition;
  final Size initialSize;
  final bool showButtons;

  const CustomDialog({
    super.key,
    required this.child,
    this.onClose,
    this.onConfirm,
    required this.title,
    required this.initialPosition,
    required this.initialSize,
    this.showButtons = false,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late Offset position;
  late Size size;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    size = widget.initialSize;
  }

  @override
  void didUpdateWidget(covariant CustomDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosition != widget.initialPosition) {
      setState(() => position = widget.initialPosition);
    }
    if (oldWidget.initialSize != widget.initialSize) {
      setState(() => size = widget.initialSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: const Color(0xFF282828).withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildBody(),
                  if (widget.showButtons) _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF30302e),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SingleChildScrollView(
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF30302e),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: widget.onClose,
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.onConfirm,
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

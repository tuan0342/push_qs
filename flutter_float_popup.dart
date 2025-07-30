import 'package:flutter/material.dart';

class FloatingPopup extends StatefulWidget {
  final Offset initialPosition;
  final Size initialSize;
  final VoidCallback onClose;
  final Widget child;

  const FloatingPopup({
    Key? key,
    required this.initialPosition,
    required this.initialSize,
    required this.onClose,
    required this.child,
  }) : super(key: key);

  @override
  State<FloatingPopup> createState() => _FloatingPopupState();
}

class _FloatingPopupState extends State<FloatingPopup> {
  late Offset position;
  late Size size;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    size = widget.initialSize;
  }

  @override
  void didUpdateWidget(FloatingPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition) {
      position = widget.initialPosition;
    }
    if (widget.initialSize != oldWidget.initialSize) {
      size = widget.initialSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 4,
                top: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                  tooltip: 'Đóng',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48.0, left: 12, right: 12, bottom: 12),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

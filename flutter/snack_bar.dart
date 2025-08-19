import 'package:flutter/material.dart';

extension Snackbars on BuildContext {
  void snack(
    String message, {
    Color? bg,
    Color? fg,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    bool replaceCurrent = true,
    IconData? icon,
  }) {
    final messenger = ScaffoldMessenger.of(this);
    if (replaceCurrent) messenger.hideCurrentSnackBar();

    final content = Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg ?? Colors.white),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(message)),
      ],
    );

    messenger.showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: bg ?? const Color(0xFF2D2D2D), // hợp nền tối
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }

  void snackSuccess(String msg) =>
      snack(msg, bg: const Color(0xFF1F4D2D), icon: Icons.check_circle);
  void snackError(String msg) =>
      snack(msg, bg: const Color(0xFF5A1F1F), icon: Icons.error);
  void snackWarn(String msg) =>
      snack(msg, bg: const Color(0xFF5A4A1F), icon: Icons.warning_amber);
  void snackInfo(String msg) =>
      snack(msg, bg: const Color(0xFF2D2D2D), icon: Icons.info);
}

import 'package:flutter/material.dart';

/// A widget that displays a progress icon based on a progress value.
///
/// - If progress equals 1, displays an orange open book icon
/// - If progress is between 0 and 1, displays a green check icon
class ProgressIcon extends StatelessWidget {
  /// The progress value, between 0 and 1 (inclusive)
  final double progress;

  /// Size of the icon
  final double? size;

  const ProgressIcon({
    super.key,
    required this.progress,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (progress >= 1.0) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: size,
      );
    }
    return Icon(
      Icons.menu_book_outlined,
      color: Colors.orange,
      size: size,
    );
  }
}

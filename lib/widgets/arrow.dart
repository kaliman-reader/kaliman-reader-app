import 'package:flutter/material.dart';

enum ArrowDirection { left, right }

class Arrow extends StatelessWidget {
  final ArrowDirection direction;
  final Function()? onPressed;
  final bool enabled;

  const Arrow({
    Key? key,
    required this.direction,
    required this.onPressed,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: const Color.fromARGB(150, 255, 255, 255),
      radius: 24.0,
      child: IconButton(
        icon: Icon(direction == ArrowDirection.left
            ? Icons.navigate_before
            : Icons.navigate_next),
        color: Colors.orange.shade700,
        iconSize: 24.0,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

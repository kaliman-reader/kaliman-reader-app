import 'package:flutter/material.dart';

class Chapter extends StatelessWidget {
  final String title;

  const Chapter({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}

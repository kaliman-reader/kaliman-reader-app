import 'package:flutter/material.dart';

class Chapter extends StatelessWidget {
  final String title;

  const Chapter({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}

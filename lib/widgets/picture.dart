import 'package:flutter/material.dart';

class Picture extends StatelessWidget {
  final String url;

  const Picture({super.key, required this.url});

  @override
  Widget build(Object context) {
    return Image.network(url);
  }
}

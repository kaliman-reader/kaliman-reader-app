import 'package:flutter/material.dart';

class Picture extends StatelessWidget {
  final String url;

  const Picture({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(Object context) {
    return Image.network(url);
  }
}

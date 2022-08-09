import 'package:flutter/material.dart';

class Story extends StatelessWidget {
  final String? title;
  final GestureTapCallback? onTap;

  const Story({Key? key, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title!),
      onTap: onTap,
    );
  }
}

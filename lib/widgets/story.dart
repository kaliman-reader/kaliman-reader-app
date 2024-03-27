import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/leading_image.dart';

class Story extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final String prefix;
  final bool isFinalFolder;

  const Story(
      {Key? key,
      required this.title,
      this.onTap,
      required this.prefix,
      required this.isFinalFolder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Image(image: LeadingImage(prefix, isFinalFolder: isFinalFolder)),
      onTap: onTap,
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/leading_image.dart';

class Story extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final String prefix;
  final bool isFinalFolder;

  const Story({
    super.key,
    required this.title,
    this.onTap,
    required this.prefix,
    required this.isFinalFolder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Image(
        image: ResizeImage(
          LeadingImage(
            prefix,
            isFinalFolder: isFinalFolder,
          ),
          width: 40,
        ),
      ),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.download),
        color: Color(Theme.of(context).colorScheme.primary.value),
        onPressed: () {
          log('Download button pressed.');
        },
      ),
    );
  }
}

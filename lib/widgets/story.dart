import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/leading_image.dart';
import 'package:kaliman_reader_app/widgets/progress_icon.dart';

typedef OnDownloadCallback = Future<void> Function(String prefix);

class Story extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final String prefix;
  final bool isFinalFolder;
  final double? progress;

  const Story({
    super.key,
    required this.title,
    this.onTap,
    required this.prefix,
    required this.isFinalFolder,
    this.progress,
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
      trailing: progress != null ? ProgressIcon(progress: progress!) : null,
      onTap: onTap,
    );
  }
}

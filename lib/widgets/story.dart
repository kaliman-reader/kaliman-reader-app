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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image that takes full height
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image(
                width: 70,
                height: 100,
                image: ResizeImage(
                  LeadingImage(
                    prefix,
                    isFinalFolder: isFinalFolder,
                  ),
                  width: 70,
                  height: 100,
                ),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Title with flexible width
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            // Progress icon if needed
            if (progress != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: ProgressIcon(progress: progress!),
              ),
          ],
        ),
      ),
    );
  }
}

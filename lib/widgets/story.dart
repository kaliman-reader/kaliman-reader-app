import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/utils/image_url.dart';
import 'package:kaliman_reader_app/widgets/progress_icon.dart';
import 'package:shimmer/shimmer.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        // Use AspectRatio for the overall container to maintain consistent sizing
        child: AspectRatio(
          aspectRatio: 0.75, // Portrait orientation for comic covers
          child: Column(
            children: [
              // Image takes most of the space
              Expanded(
                flex: 9,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image(
                      image: NetworkImage(
                        getCoverUrl(prefix),
                      ),
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        }
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 120,
                            height: 170,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Icon and text area
              Expanded(
                flex: 3,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Progress icon if needed
                      if (progress != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: ProgressIcon(progress: progress!, size: 20),
                        ),
                      // Title with text centered
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height:
                                        1, // Tighter line height to fit text better
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

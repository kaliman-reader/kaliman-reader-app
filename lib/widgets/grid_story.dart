import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/leading_image.dart';

class GridStory extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final String prefix;
  final bool isFinalFolder;

  const GridStory({
    super.key,
    required this.title,
    this.onTap,
    required this.prefix,
    required this.isFinalFolder,
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
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image(
                      image: LeadingImage(
                        prefix,
                        isFinalFolder: isFinalFolder,
                      ),
                    ),
                  ),
                ),
              ),
              // Text area has a fixed proportion
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 2),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height:
                                1.2, // Tighter line height to fit text better
                          ),
                    ),
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

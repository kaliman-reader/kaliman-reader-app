import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/leading_image.dart';

class GridStory extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final String prefix;
  final bool isFinalFolder;

  const GridStory(
      {super.key,
      required this.title,
      this.onTap,
      required this.prefix,
      required this.isFinalFolder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image(
                image: ResizeImage(
                  LeadingImage(
                    prefix,
                    isFinalFolder: isFinalFolder,
                  ),
                  width: 120,
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(
                title,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

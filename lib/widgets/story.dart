import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/leading_image.dart';

typedef OnDownloadCallback = Future<void> Function(String prefix);

class Story extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final String prefix;
  final bool isFinalFolder;
  final bool downloadable;
  final OnDownloadCallback onDownload;

  const Story({
    super.key,
    required this.title,
    this.onTap,
    required this.prefix,
    required this.isFinalFolder,
    required this.onDownload,
    required this.downloadable,
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
        icon: downloadable
            ? const Icon(Icons.download)
            : const Icon(Icons.check_circle),
        color: Color(
          Theme.of(context).colorScheme.primary.value,
        ),
        tooltip: 'Descargar como PDF',
        disabledColor: Colors.green,
        onPressed: downloadable
            ? () async {
                await onDownload(prefix);
              }
            : null,
      ),
    );
  }
}

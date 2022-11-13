import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/providers/picture_key_image.dart';
import 'package:kaliman_reader_app/repositories/object_key_repository.dart';
import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:kaliman_reader_app/services/picture_sorter.dart';
import 'package:kaliman_reader_app/widgets/arrow.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ReaderPage extends StatefulWidget {
  final String prefix;
  const ReaderPage({Key? key, required this.prefix}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  String? currentPictureUrl;
  List<PictureKey> pictureKeys = [];

  @override
  void initState() {
    getObjectKeys();
    super.initState();
  }

  getObjectKeys() async {
    pictureKeys = await ObjectKeyRepository.getKeys(widget.prefix);
    setState(() {
      pictureKeys = PictureKeySorter.sort(pictureKeys);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          log(index.toString(), level: 1);
          return PhotoViewGalleryPageOptions(
            imageProvider: PictureKeyImage(pictureKeys[index].key),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes:
                PhotoViewHeroAttributes(tag: pictureKeys[index].key),
          );
        },
        itemCount: pictureKeys.length,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        onPageChanged: (index) {
          log('khe', level: 50);
        },
      ),
    );
  }
}

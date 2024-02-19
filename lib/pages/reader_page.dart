import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:kaliman_reader_app/providers/picture_key_image.dart';
import 'package:kaliman_reader_app/repositories/object_key_repository.dart';
import 'package:kaliman_reader_app/services/picture_sorter.dart';
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
  bool _loading = true;

  setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

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
    setLoading(false);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
        body: Stack(children: [
      Center(
          child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: _loading == true ? const CircularProgressIndicator() : null,
      )),
      PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          if (index + 1 < pictureKeys.length) {
            precacheImage(PictureKeyImage(pictureKeys[index + 1].key), context);
          }
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
      ),
    ]));
  }
}

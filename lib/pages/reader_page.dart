import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/repositories/object_key_repository.dart';
import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:kaliman_reader_app/widgets/arrow.dart';

class ReaderPage extends StatefulWidget {
  final String prefix;
  const ReaderPage({Key? key, required this.prefix}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  String? currentPictureUrl;
  int _index = 0;
  bool _showButtons = false;
  List<PictureKey> pictureKeys = [];

  @override
  void initState() {
    getObjectKeys();
    super.initState();
  }

  getObjectKeys() async {
    pictureKeys = await ObjectKeyRepository.getKeys(widget.prefix);
    pictureKeys.removeAt(0);
    getPicture(0);
  }

  getPicture(int index) async {
    if (pictureKeys.isNotEmpty) {
      var picture = await ObjectRepository.getObject(pictureKeys[index].key);
      setState(() {
        currentPictureUrl = picture.url;
      });
    } else {
      log('No se encontraron resultados', level: 200);
    }
  }

  toggleButtons() {
    setState(() {
      _showButtons = !_showButtons;
    });
  }

  nextPicture() {
    setState(() {
      if (_index < pictureKeys.length) _index++;
      getPicture(_index);
    });
  }

  previousPicture() {
    setState(() {
      if (_index > 0) _index--;
      getPicture(_index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prefix),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => toggleButtons(),
            child: currentPictureUrl != null
                ? Image.network(currentPictureUrl!)
                : const Text('Cargando...'),
          ),
          SizedBox.expand(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _showButtons
                  ? [
                      Arrow(
                        direction: ArrowDirection.left,
                        enabled: _index > 0,
                        onPressed: (() {
                          previousPicture();
                        }),
                      ),
                      Arrow(
                        direction: ArrowDirection.right,
                        enabled: _index < pictureKeys.length,
                        onPressed: (() {
                          nextPicture();
                        }),
                      ),
                    ]
                  : [],
            ),
          )
        ],
      ),
    );
  }
}

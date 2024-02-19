import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:kaliman_reader_app/pages/reader_page.dart';

import '../widgets/story.dart';

class SubFolderPage extends StatefulWidget {
  final List<Prefix> prefixes;
  const SubFolderPage({Key? key, required this.prefixes}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SubFolderPageState();
}

class _SubFolderPageState extends State<SubFolderPage> {
  void goToReaderPage(context, prefix) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ReaderPage(prefix: prefix)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capítulos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: widget.prefixes.map((e) {
            return Story(
                title: e.prefix.replaceAllMapped(
                    RegExp(r'\/(.*)\/'), (match) => ' (${match[1]})'),
                onTap: () {
                  goToReaderPage(context, e.prefix);
                });
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:kaliman_reader_app/pages/reader_page.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';

import '../widgets/story.dart';

class SubFolderPage extends StatefulWidget {
  final List<Prefix> prefixes;
  const SubFolderPage({super.key, required this.prefixes});
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
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: widget.prefixes.map((e) {
                  return Story(
                    title: e.prefix.replaceAllMapped(
                        RegExp(r'\/(.*)\/'), (match) => ' (${match[1]})'),
                    onTap: () {
                      goToReaderPage(context, e.prefix);
                    },
                    prefix: e.prefix,
                    isFinalFolder: true,
                  );
                }).toList(),
              ),
            ),
            const AdBanner(),
          ],
        ));
  }
}

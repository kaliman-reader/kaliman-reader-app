import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:kaliman_reader_app/pages/reader_page.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';

import '../widgets/story.dart';

class SubFolderPage extends StatefulWidget {
  final List<Prefix> prefixes;
  final Prefix prefix;

  const SubFolderPage(
      {super.key, required this.prefixes, required this.prefix});
  @override
  State<StatefulWidget> createState() => _SubFolderPageState();
}

class _SubFolderPageState extends State<SubFolderPage> {
  void goToReaderPage(context, prefix) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ReaderPage(prefix: prefix)));
  }

  @override
  void initState() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'subfolder_page',
      screenClass: 'SubFolderPage',
      parameters: {'prefix': widget.prefixes[0].prefix},
    );
    super.initState();
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
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60),
            child: ListView.builder(
              itemCount: widget.prefixes.length,
              itemBuilder: (context, index) {
                final prefix = widget.prefixes[index].prefix;
                return Story(
                  title: prefix.replaceAllMapped(
                      RegExp(r'\/(.*)\/'), (match) => ' (${match[1]})'),
                  onTap: () {
                    goToReaderPage(context, prefix);
                  },
                  prefix: prefix,
                  isFinalFolder: true,
                );
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kaliman_reader_app/pages/reader_page.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';
import 'package:kaliman_reader_app/widgets/story.dart';

import 'models/prefix.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector de Kaliman',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Lector de Kaliman'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String prefix = '';
  List<Prefix> firstLevelPrefixes = [];

  @override
  void initState() {
    getPrefixes();
    super.initState();
  }

  Future<void> getPrefixes() async {
    var prefixes = await PrefixRepository.getPrefixes(prefix);
    setState(() {
      firstLevelPrefixes = prefixes;
    });
  }

  void goToReaderPage(context, prefix) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ReaderPage(prefix: prefix)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias de Kaliman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: firstLevelPrefixes.map((e) {
            return Story(
                title: e.prefix,
                onTap: () {
                  if (prefix.isEmpty) {
                    setState(() {
                      prefix = e.prefix;
                      getPrefixes();
                    });
                  } else {
                    goToReaderPage(context, e.prefix);
                  }
                });
          }).toList(),
        ),
      ),
    );
  }
}

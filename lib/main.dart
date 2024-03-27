import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/pages/subfolder.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';
import 'package:kaliman_reader_app/widgets/story.dart';

import 'models/prefix.dart';

Future main() async {
  await dotenv.load();
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
          primarySwatch: Colors.orange, splashFactory: InkRipple.splashFactory),
      home: const MyHomePage(title: 'Lector de Kaliman'),
      scaffoldMessengerKey: scaffoldMessengerKey,
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
  List<Prefix> firstLevelPrefixes = [];

  var _loading = false;

  @override
  void initState() {
    getPrefixes(Prefix(prefix: ""));
    super.initState();
  }

  setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Future<void> getPrefixes(Prefix prefix) async {
    try {
      var prefixes = await PrefixRepository.getPrefixes(prefix.prefix);
      setState(() {
        firstLevelPrefixes = prefixes;
      });
    } catch (exception) {
      log(exception.toString(),
          name: 'app.openlinks.kaliman.prefixes', error: exception);
    }
  }

  void goToSubFolderPage(List<Prefix> prefixes) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SubFolderPage(prefixes: prefixes)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historias de Kaliman'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Center(
                  child: SizedBox(
                width: 20.0,
                height: 20.0,
                child:
                    _loading == true ? const CircularProgressIndicator() : null,
              )),
              ListView(
                children: firstLevelPrefixes.map((e) {
                  return Story(
                      title: e.prefix.replaceAll(RegExp(r'\/'), ''),
                      prefix: e.prefix,
                      isFinalFolder: false,
                      onTap: () async {
                        setLoading(true);
                        try {
                          var prefixes =
                              await PrefixRepository.getPrefixes(e.prefix);
                          goToSubFolderPage(prefixes);
                        } catch (err) {
                          var state = scaffoldMessengerKey.currentState;
                          state?.showSnackBar(const SnackBar(
                            content: Text(
                                '¡Pronto tendremos más novedades para ti!'),
                          ));
                        } finally {
                          setLoading(false);
                        }
                      });
                }).toList(),
              ),
            ],
          )),
    );
  }
}

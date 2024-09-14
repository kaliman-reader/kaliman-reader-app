import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/pages/subfolder.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';
import 'package:kaliman_reader_app/widgets/grid_story.dart';
import 'package:kaliman_reader_app/widgets/the-app-drawer.dart';

import 'models/prefix.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector de Kaliman',
      themeMode: ThemeMode.system,
      theme: ThemeData.from(
        colorScheme: ColorScheme.light(primary: Color(Colors.orange.value)),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.dark(primary: Color(Colors.deepOrange.value)),
      ),
      home: const MyHomePage(title: 'Lector de Kaliman'),
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
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
          name: 'app.openlinks.kaliman_reader_app.prefixes', error: exception);
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
      drawer: const TheAppDrawer(),
      appBar: AppBar(
        title: const Text('Aventuras de Kaliman'),
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
              GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 40),
                  padding: const EdgeInsets.only(bottom: 50),
                  children: firstLevelPrefixes.map((e) {
                    return GridStory(
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
                  }).toList()),
              const AdBanner(),
            ],
          )),
    );
  }
}

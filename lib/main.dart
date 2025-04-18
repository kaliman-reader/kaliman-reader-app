import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/firebase_options.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:kaliman_reader_app/pages/subfolder.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';
import 'package:kaliman_reader_app/utils/layout_utils.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';
import 'package:kaliman_reader_app/widgets/grid_story.dart';
import 'package:kaliman_reader_app/widgets/the_app_drawer.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lector de Kaliman',
      themeMode: ThemeMode.system,
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(primary: Colors.orange),
      ),
      darkTheme: ThemeData.from(
        colorScheme: const ColorScheme.dark(primary: Colors.deepOrange),
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
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'home_page',
      screenClass: 'MyHomePage',
    );
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
      FirebaseAnalytics.instance.logEvent(name: 'prefixes_error', parameters: {
        'error': exception.toString(),
        'stack_trace': Error().stackTrace.toString(),
        'prefix': prefix.prefix
      });
      log(exception.toString(),
          name: 'app.openlinks.kaliman_reader_app.prefixes', error: exception);
    }
  }

  void goToSubFolderPage(Prefix prefix, List<Prefix> prefixes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubFolderPage(
          prefixes: prefixes,
          prefix: prefix,
        ),
      ),
    );
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
                  child: _loading == true
                      ? const CircularProgressIndicator()
                      : null,
                ),
              ),
              LayoutBuilder(builder: (context, constraints) {
                // Calculate number of columns based on available width
                final double width = constraints.maxWidth;
                // Responsive column count based on screen width
                final int crossAxisCount = getColumnCountForHome(width);

                return GridView.builder(
                  cacheExtent: MediaQuery.of(context).size.width * 2,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: firstLevelPrefixes.length,
                  itemBuilder: (context, index) {
                    final currentPrefix = firstLevelPrefixes[index];
                    return GridStory(
                      title: currentPrefix.prefix
                          .replaceAll(RegExp(r'\/'), '')
                          .replaceAll(RegExp(r'A\.|K\.'), ''),
                      prefix: currentPrefix.prefix,
                      isFinalFolder: false,
                      onTap: () async {
                        setLoading(true);
                        try {
                          var prefixes = await PrefixRepository.getPrefixes(
                              currentPrefix.prefix);
                          goToSubFolderPage(currentPrefix, prefixes);
                        } catch (err) {
                          var state = scaffoldMessengerKey.currentState;
                          state?.showSnackBar(const SnackBar(
                            content: Text(
                                '¡Pronto tendremos más novedades para ti!'),
                          ));
                        } finally {
                          setLoading(false);
                        }
                      },
                    );
                  },
                );
              }),
              const AdBanner(),
            ],
          )),
    );
  }
}

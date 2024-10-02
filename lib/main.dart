import 'dart:developer';

import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/firebase_options.dart';
import 'package:kaliman_reader_app/pages/subfolder.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';
import 'package:kaliman_reader_app/widgets/grid_story.dart';
import 'package:kaliman_reader_app/widgets/the_app_drawer.dart';

import 'models/prefix.dart';

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
  late ConfettiController _confettiController;

  List<Prefix> firstLevelPrefixes = [];

  var _loading = false;

  @override
  void initState() {
    getPrefixes(Prefix(prefix: ""));
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'home_page',
      screenClass: 'MyHomePage',
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
      FirebaseAnalytics.instance.logEvent(name: 'error', parameters: {
        'error': exception.toString(),
        'stack_trace': Error().stackTrace.toString(),
        'prefix': prefix.prefix
      });
      log(
        exception.toString(),
        name: 'app.openlinks.kaliman_reader_app.prefixes',
        error: exception,
      );
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
      drawer: TheAppDrawer(
        onDonationTap: () async {
          await InAppPurchase.instance.buyNonConsumable(
            purchaseParam: PurchaseParam(
              productDetails: ProductDetails(
                id: 'donation',
                title: 'Donación',
                description: 'Apoya el desarrollo de la app',
                price: 'USD 50.00',
                rawPrice: 1.0,
                currencyCode: 'USD',
              ),
            ),
          );
          _confettiController.play();
        },
      ),
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
              ),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 40),
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: firstLevelPrefixes.length,
              itemBuilder: (context, index) {
                final currentPrefix = firstLevelPrefixes[index];
                return GridStory(
                  title: currentPrefix.prefix.replaceAll(RegExp(r'\/'), ''),
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
                        content:
                            Text('¡Pronto tendremos más novedades para ti!'),
                      ));
                    } finally {
                      setLoading(false);
                    }
                  },
                );
              },
            ),
            const AdBanner(),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.5,
                numberOfParticles: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

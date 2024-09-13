import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/pages/subfolder.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';
import 'package:kaliman_reader_app/widgets/grid_story.dart';

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
      theme: ThemeData(
          primarySwatch: Colors.orange, splashFactory: InkRipple.splashFactory),
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

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  final String _adUnitId = dotenv.get('AD_BANNER_UNIT_ID');

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
    _loadAd();
    return Scaffold(
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
              if (_bannerAd != null && _isBannerLoaded)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Ink(
                      color: Color(Colors.white.value),
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  void _loadAd() async {
    if (!mounted) {
      return;
    }

    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    const size = AdSize.banner;

    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          log('Ad failed to load: $err');
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {
          log('Ad opened.');
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }
}

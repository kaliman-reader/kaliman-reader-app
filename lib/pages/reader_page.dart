import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:kaliman_reader_app/providers/picture_key_image.dart';
import 'package:kaliman_reader_app/repositories/object_key_repository.dart';
import 'package:kaliman_reader_app/services/image_download_service.dart';
import 'package:kaliman_reader_app/services/image_share_service.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderPage extends StatefulWidget {
  final String prefix;
  const ReaderPage({super.key, required this.prefix});
  @override
  State<StatefulWidget> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  List<PictureKey> pictureKeys = [];
  String? currentPictureUrl;
  int currentPictureIndex = 0;
  bool _loading = true;
  bool _showAppBar = false;
  var downloadIcon = Icons.download;
  late SharedPreferences _prefs;
  var pageController = PageController();
  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;
  final String adUnitId = dotenv.get('AD_INTERSTITIAL_UNIT_ID');
  static const platform =
      MethodChannel('app.openlinks.kaliman_reader_app/buttons');

  setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  void initState() {
    getObjectKeys();
    _loadAd();
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'reader_page',
      screenClass: 'ReaderPage',
      parameters: {'prefix': widget.prefix},
    );
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      getObjectKeys();
    });

    platform.setMethodCallHandler((call) async {
      if (call.method == 'volume_button') {
        String button = call.arguments as String? ?? 'unknown';
        setState(() {
          if (button == "VOLUME_UP") {
            if (currentPictureIndex > 0) {
              pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } else if (button == "VOLUME_DOWN") {
            if (currentPictureIndex < pictureKeys.length - 1) {
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      }
      return; // no result needed for one-way call
    });

    super.initState();
  }

  getObjectKeys() async {
    pictureKeys = await ObjectKeyRepository.getKeys(widget.prefix);
    currentPictureUrl = pictureKeys[0].key;
    setLoading(false);
    final progress = _prefs.getDouble(widget.prefix);
    if (progress != null) {
      pageController.animateToPage(
        (progress * pictureKeys.length).floor() - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: Text('${currentPictureIndex + 1}/${pictureKeys.length}'),
              actions: [
                IconButton(
                  icon: Icon(downloadIcon),
                  onPressed: () async {
                    var path = await ImageDownloadService.downloadImage(
                      currentPictureUrl!,
                      widget.prefix,
                      currentPictureIndex,
                    );
                    var state = scaffoldMessengerKey.currentState;
                    state?.showSnackBar(SnackBar(
                      content: Text('Página guardada en: $path'),
                    ));
                    setState(() {
                      downloadIcon = Icons.download_done;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await ImageShareService.shareImage(currentPictureUrl!);
                  },
                ),
              ],
            )
          : null,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvoked,
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
            Column(children: [
              Expanded(
                child: PhotoViewGallery.builder(
                  scrollPhysics: const PageScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    if (index + 1 < pictureKeys.length) {
                      precacheImage(
                          PictureKeyImage(pictureKeys[index + 1].key), context);
                    }
                    return PhotoViewGalleryPageOptions(
                      imageProvider: PictureKeyImage(pictureKeys[index].key),
                      initialScale: PhotoViewComputedScale.contained,
                      onTapUp: (context, details, controllerValue) => setState(
                        () => _showAppBar = !_showAppBar,
                      ),
                      heroAttributes:
                          PhotoViewHeroAttributes(tag: pictureKeys[index].key),
                    );
                  },
                  itemCount: pictureKeys.length,
                  pageController: pageController,
                  onPageChanged: (index) async {
                    FirebaseAnalytics.instance.logScreenView(
                      screenName: 'reader_page',
                      screenClass: 'ReaderPage',
                      parameters: {'prefix': pictureKeys[index].key},
                    );
                    await _prefs.setDouble(
                      widget.prefix,
                      (index + 1).toDouble() / pictureKeys.length,
                    );
                    setState(() {
                      currentPictureUrl = pictureKeys[index].key;
                      currentPictureIndex = index;
                      downloadIcon = Icons.download;
                    });
                  },
                  loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!,
                      ),
                    ),
                  ),
                ),
              ),
              const AdBanner(),
            ])
          ],
        ),
      ),
    );
  }

  void _onPopInvoked(bool didPop, Object? result) async {
    log('pop invoked $didPop ');
    if (didPop) {
      return;
    }
    if (currentPictureIndex < 5) {
      log('Not showing interstitial ad because currentPictureIndex is less than 5');
      Navigator.pop(context, result);
      return;
    }
    if (_interstitialAd == null) {
      Navigator.pop(context, result);
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
      },
    );

    final bool shouldPop = await _showInterstitialAd();
    if (mounted && shouldPop) {
      Navigator.pop(context, result);
    }
  }

  Future<bool> _showInterstitialAd() async {
    if (_isAdLoaded) {
      await _interstitialAd!.show();
      return true;
    }
    return true;
  }

  void _loadAd() async {
    if (!mounted) {
      log('Called to load but not mounted.');
      return;
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() {
            _isAdLoaded = false;
            _interstitialAd = null;
          });
          log('InterstitialAd failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );
  }
}

import 'dart:developer';

import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:kaliman_reader_app/repositories/object_key_repository.dart';
import 'package:kaliman_reader_app/services/image_download_service.dart';
import 'package:kaliman_reader_app/services/image_share_service.dart';
import 'package:kaliman_reader_app/services/pdf_download_service.dart';
import 'package:kaliman_reader_app/services/purchase_pdf_service.dart';
import 'package:kaliman_reader_app/utils/image_url.dart';
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
      MethodChannel('app.openlinks.comic_reader_app/buttons');
  var pagesRead = 0;
  late ConfettiController _confettiController;
  var downloadedPrefixes = <String>[];
  bool _loadingPayment = false;

  setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  void _handlePurchases() async {
    InAppPurchase.instance.restorePurchases();
    InAppPurchase.instance.purchaseStream.listen((
      List<PurchaseDetails> purchases,
    ) async {
      for (var purchaseDetails in purchases) {
        log('${purchaseDetails.status}: ${purchaseDetails.productID}');
        if (purchaseDetails.status == PurchaseStatus.canceled) {
          setState(() {
            _loadingPayment = false;
          });
        }
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          var path = await PdfDownloadService.downloadPdf(widget.prefix);
          var state = scaffoldMessengerKey.currentState;
          _confettiController.play();
          state?.showSnackBar(SnackBar(
            content: Text('Página guardada en: $path'),
          ));
          setState(() {
            _loadingPayment = false;
            downloadedPrefixes.add(widget.prefix);
            _prefs.setStringList(downloadedPrefixesKey, downloadedPrefixes);
          });
        }
        if (purchaseDetails.status == PurchaseStatus.error) {
          FirebaseAnalytics.instance.logEvent(
            name: 'purchase_error',
            parameters: {
              'error': 'Purchase error',
              'stack_trace': Error().stackTrace.toString(),
              'prefix': widget.prefix
            },
          );
          setState(() {
            _loadingPayment = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    getObjectKeys();
    _loadAd();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _handlePurchases();
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'reader_page',
      screenClass: 'ReaderPage',
      parameters: {'prefix': widget.prefix},
    );
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      downloadedPrefixes = _prefs.getStringList(downloadedPrefixesKey) ?? [];
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
    pictureKeys = pictureKeys
        .where(
          (e) => !e.key.contains('thumbnail'),
        )
        .toList();
    currentPictureUrl = pictureKeys[0].key;
    setLoading(false);
    final progress = _prefs.getDouble(widget.prefix);
    if (progress != null && progress != 1) {
      final index = (progress * pictureKeys.length).floor() - 1;
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPictureIndex = index;
        pagesRead = 0;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _confettiController.dispose();
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
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    _showPdfDownloadDialog();
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
                        NetworkImage(
                          getImageUrl(pictureKeys[index + 1].key),
                        ),
                        context,
                      );
                    }
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                          NetworkImage(getImageUrl(pictureKeys[index].key)),
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
                    await _prefs.setDouble(
                      widget.prefix,
                      (index + 1).toDouble() / pictureKeys.length,
                    );
                    FirebaseAnalytics.instance.logScreenView(
                      screenName: 'reader_page',
                      screenClass: 'ReaderPage',
                      parameters: {'prefix': pictureKeys[index].key},
                    );
                    setState(() {
                      currentPictureUrl = pictureKeys[index].key;
                      // We increment pagesRead when user moves forward in the comic
                      // currentPictureIndex is the previous page
                      // index is the new page they're moving to
                      // So if previous < new, they're moving forward
                      if (currentPictureIndex < index) {
                        pagesRead++;
                      }
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
            ]),
            Center(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.directional,
                blastDirection: -3.14 / 2, // equivalent to -pi / 2
                emissionFrequency: 0.2,
                numberOfParticles: 20,
                gravity: 0.3,
              ),
            ),
            if (_loadingPayment)
              Container(
                color: Colors.black
                    .withValues(alpha: 0.5), // Semi-transparent black backdrop
                child: const Center(
                  child: Text(
                    'Adquiriendo cómic...',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
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
    if (pagesRead < 10 && currentPictureIndex <= pictureKeys.length - 1) {
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

  void _showPdfDownloadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Descargar Cómic Completo en PDF'),
          content: const Text(
              'Obtén el cómic completo en formato PDF de alta calidad en español. \n\n¿Deseas continuar con la descarga?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _loadingPayment = true;
                });
                await PurchasePdfService.buyPdf(widget.prefix);
              },
            ),
          ],
        );
      },
    );
  }
}

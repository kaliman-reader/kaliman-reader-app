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
import 'package:kaliman_reader_app/services/picture_sorter.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;
  final String adUnitId = dotenv.get('AD_INTERSTITIAL_UNIT_ID');

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
    super.initState();
  }

  getObjectKeys() async {
    pictureKeys = await ObjectKeyRepository.getKeys(widget.prefix);
    currentPictureUrl = pictureKeys[0].key;
    setState(() {
      pictureKeys = PictureKeySorter.sort(pictureKeys);
    });
    setLoading(false);
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
              title: Text('$currentPictureIndex/${pictureKeys.length}'),
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
                  onPageChanged: (index) {
                    FirebaseAnalytics.instance.logScreenView(
                      screenName: 'reader_page',
                      screenClass: 'ReaderPage',
                      parameters: {'prefix': pictureKeys[index].key},
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
    if (didPop) {
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
    return false;
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
          log('InterstitialAd failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );
  }
}

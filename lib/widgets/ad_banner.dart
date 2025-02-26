import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<StatefulWidget> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  final String _adUnitId = dotenv.get('AD_BANNER_UNIT_ID');

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isBannerLoaded) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Ink(
            color: Color(Theme.of(context).scaffoldBackgroundColor.value),
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() async {
    if (!mounted) {
      log('Called to load but not mounted.');
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
        onAdFailedToLoad: (ad, err) async {
          log('Ad failed to load: $err');
          await ad.dispose();
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

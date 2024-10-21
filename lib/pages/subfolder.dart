import 'dart:developer';

import 'package:confetti/confetti.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:kaliman_reader_app/pages/reader_page.dart';
import 'package:kaliman_reader_app/services/pdf_download_service.dart';
import 'package:kaliman_reader_app/services/purchase_pdf_service.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/story.dart';

class SubFolderPage extends StatefulWidget {
  final List<Prefix> prefixes;
  final Prefix prefix;

  const SubFolderPage(
      {super.key, required this.prefixes, required this.prefix});
  @override
  State<StatefulWidget> createState() => _SubFolderPageState();
}

class _SubFolderPageState extends State<SubFolderPage> {
  late String _prefixToBuy;
  late ConfettiController _confettiController;
  late SharedPreferences _prefs;
  List<String> downloadedPrefixes = [];
  bool _loadingPayment = false;

  void goToReaderPage(context, prefix) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderPage(prefix: prefix),
      ),
    );
  }

  @override
  void initState() {
    _prefixToBuy = widget.prefixes[0].prefix;
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      downloadedPrefixes = _prefs.getStringList(downloadedPrefixesKey) ?? [];
    });
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'subfolder_page',
      screenClass: 'SubFolderPage',
      parameters: {'prefix': widget.prefixes[0].prefix},
    );
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
          var path = await PdfDownloadService.downloadPdf(_prefixToBuy);
          var state = scaffoldMessengerKey.currentState;
          _confettiController.play();
          state?.showSnackBar(SnackBar(
            content: Text('Página guardada en: $path'),
          ));
          setState(() {
            _loadingPayment = false;
            downloadedPrefixes.add(_prefixToBuy);
            _prefs.setStringList(downloadedPrefixesKey, downloadedPrefixes);
          });
        }
        if (purchaseDetails.status == PurchaseStatus.error) {
          FirebaseAnalytics.instance.logEvent(
            name: 'purchase_error',
            parameters: {
              'error': 'Purchase error',
              'stack_trace': Error().stackTrace.toString(),
              'prefix': _prefixToBuy
            },
          );
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capítulos"),
      ),
      body: Stack(
        children: [
          Center(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.directional,
              blastDirection: -3.14 / 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 60),
            child: ListView.builder(
              itemCount: widget.prefixes.length,
              itemBuilder: (context, index) {
                final prefix = widget.prefixes[index].prefix;
                return Story(
                  title: prefix.replaceAllMapped(
                      RegExp(r'\/(.*)\/'), (match) => ' (${match[1]})'),
                  onTap: () {
                    goToReaderPage(context, prefix);
                  },
                  downloadable: !downloadedPrefixes.contains(prefix),
                  onDownload: (prefix) async {
                    setState(() {
                      _prefixToBuy = prefix;
                      _loadingPayment = true;
                    });
                    await PurchasePdfService.buyPdf(prefix);
                  },
                  prefix: prefix,
                  isFinalFolder: true,
                );
              },
            ),
          ),
          const AdBanner(),
          Center(
            child: _loadingPayment == true
                ? Dialog.fullscreen(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          Text(
                            'Descargando...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Text(
                            'Esto tardará unos pocos segundos...',
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:kaliman_reader_app/pages/reader_page.dart';
import 'package:kaliman_reader_app/services/pdf_download_service.dart';
import 'package:kaliman_reader_app/services/purchase_pdf_service.dart';
import 'package:kaliman_reader_app/widgets/ad_banner.dart';

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
  void goToReaderPage(context, prefix) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ReaderPage(prefix: prefix)));
  }

  @override
  void initState() {
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'subfolder_page',
      screenClass: 'SubFolderPage',
      parameters: {'prefix': widget.prefixes[0].prefix},
    );
    InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) async {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);
          }
          FirebaseAnalytics.instance.logPurchase();
          await PdfDownloadService.downloadPdf(purchaseDetails.productID);
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
            content: Text('¡PDF descargado y guardado!'),
          ));
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
                  onDownload: (prefix) async {
                    await PurchasePdfService.buyPdf(prefix);
                  },
                  prefix: prefix,
                  isFinalFolder: true,
                );
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

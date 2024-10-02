import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TheAppDrawer extends StatelessWidget {
  final Function onDonationTap;

  const TheAppDrawer({super.key, required this.onDonationTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                color: Color(Theme.of(context).scaffoldBackgroundColor.value),
              ),
              padding: const EdgeInsets.all(0),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/kaliman-cover.jpg'),
              )),
          ListTile(
            onTap: () {
              FirebaseAnalytics.instance
                  .logEvent(name: 'view_app_listing', parameters: {
                'app_id': playStoreUrl,
              });
              InAppReview.instance.openStoreListing();
            },
            leading: Icon(
              Icons.star,
              color: Color(Theme.of(context).colorScheme.primary.value),
            ),
            title: const Text('Danos amor'),
          ),
          ListTile(
            onTap: () async {
              FirebaseAnalytics.instance.logShare(
                  contentType: 'url', itemId: playStoreUrl, method: 'share');
              await Share.share(
                '¡Hola! Te invito a descargar el Lector de Kaliman donde podrás leer todas las aventuras. ¡Es gratis! $playStoreUrl',
              );
            },
            leading: Icon(
              Icons.share,
              color: Color(Theme.of(context).colorScheme.primary.value),
            ),
            title: const Text('Comparte con tus amigos'),
          ),
          ListTile(
            onTap: () async {
              FirebaseAnalytics.instance
                  .logEvent(name: 'view_url', parameters: {
                'url': facebookGroupUrl,
              });
              await launchUrl(Uri.parse(facebookGroupUrl));
            },
            leading: Icon(
              Icons.facebook_outlined,
              color: Color(Theme.of(context).colorScheme.primary.value),
            ),
            title: const Text('Grupo de Facebook'),
          ),
          ListTile(
            onTap: () {
              FirebaseAnalytics.instance.logEvent(name: 'donation_intent');
              Navigator.pop(context);
              onDonationTap();
            },
            leading: Icon(
              Icons.card_giftcard,
              color: Color(Theme.of(context).colorScheme.primary.value),
            ),
            title: const Text('Hacer una donación'),
          ),
        ],
      ),
    );
  }
}

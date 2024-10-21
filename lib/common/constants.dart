import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['API_URL'];
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
const String facebookGroupUrl =
    'https://www.facebook.com/groups/432120258169258/';
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=app.openlinks.kaliman_reader_app';

const String downloadedPrefixesKey = 'DOWNLOADED_PREFIXES';
const String disclaimerText = '''
Nos alegra que formes parte de esta increíble comunidad de Kaliamigos. La publicidad y las compras dentro de la aplicación nos permiten seguir desarrollando la plataforma, mantener los servidores y ofrecer una mejor experiencia para todos los seguidores de Kalimán, el hombre increíble.

Gracias a tu apoyo, podemos seguir organizando, desarrollando y mejorando la calidad del contenido que obtenemos de diversas fuentes públicas de internet, garantizando que siempre encuentres información relevante y de calidad sobre tu héroe favorito.

Tu contribución es clave para que podamos continuar mejorando esta experiencia para todos los Kaliamigos. ¡Gracias por ser parte de esta gran aventura junto a Kalimán!
''';

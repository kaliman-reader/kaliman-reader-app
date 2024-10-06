import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['API_URL'];
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
const String facebookGroupUrl =
    'https://www.facebook.com/groups/432120258169258/';
const String playStoreUrl =
    'https://play.google.com/store/apps/details?id=app.openlinks.kaliman_reader_app';

const String downloadComicId = '';

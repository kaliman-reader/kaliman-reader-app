import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['API_URL'];
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

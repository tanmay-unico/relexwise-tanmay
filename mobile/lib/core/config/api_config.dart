import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String resolveBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }
}



import 'dart:io';
import 'package:flutter/foundation.dart';

class Constants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000'; // For local web testing. Change to your domain if hosted.
    }
    // Use 10.0.2.2 for Android Emulator, or local IP for physical device
    // Local IP: 192.168.1.12
    return 'http://192.168.1.12:5000';
  }
}

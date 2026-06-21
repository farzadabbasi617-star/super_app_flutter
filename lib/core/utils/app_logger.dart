import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

enum LogLevel { info, warning, error, debug }

class AppLogger {
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final formattedMessage =
          '[$timestamp] [${level.name.toUpperCase()}] $message';

      switch (level) {
        case LogLevel.info:
          dev.log(formattedMessage);
          break;
        case LogLevel.warning:
          dev.log(formattedMessage, name: 'WARNING');
          break;
        case LogLevel.error:
          dev.log(
            formattedMessage,
            name: 'ERROR',
            error: error,
            stackTrace: stackTrace,
          );
          break;
        case LogLevel.debug:
          dev.log(formattedMessage, name: 'DEBUG');
          break;
      }
    }
  }
}

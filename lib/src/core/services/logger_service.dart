import 'package:logger/logger.dart';

/// A simple logger service that can be used throughout the application.
///
/// This service provides a global logger instance that can be configured
/// with different log levels and output formats.
///
/// To use the logger, simply import this file and call the `log` methods:
///
/// ```dart
/// import 'package:zenigo/src/core/services/logger_service.dart';
///
/// void myFunction() {
///   logger.i('This is an informational message.');
///   logger.w('This is a warning message.');
///   logger.e('This is an error message.');
/// }
/// ```
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);
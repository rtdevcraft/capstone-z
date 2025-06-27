class ProgressException implements Exception {
  const ProgressException(this.message);
  final String message;

  @override
  String toString() => 'ProgressException: $message';
}
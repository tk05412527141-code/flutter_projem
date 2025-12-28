class AppFailure {
  const AppFailure({
    required this.message,
    this.code,
    this.exception,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final Object? exception;
  final StackTrace? stackTrace;
}
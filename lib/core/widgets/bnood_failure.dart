/// Lightweight error surface for foundation Toaster (not SmartRx Failure).
class BnoodFailure {
  const BnoodFailure({required this.message, this.title});

  final String message;
  final String? title;
}

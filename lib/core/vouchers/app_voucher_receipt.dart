class AppVoucherReceipt {
  const AppVoucherReceipt({
    required this.id,
    required this.mime,
    required this.size,
    required this.createdAt,
  });

  final String id;
  final String mime;
  final int size;
  final DateTime createdAt;

  static AppVoucherReceipt fromDataJson(Map<String, dynamic> json) {
    return AppVoucherReceipt(
      id: json['id'] as String,
      mime: json['mime'] as String,
      size: (json['size'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }
}

/// One receipt row in [VoucherSheet] — local pending upload or server-backed file.
class VoucherSheetReceipt {
  const VoucherSheetReceipt({
    required this.localPath,
    this.serverId,
    this.needsUpload = false,
  });

  final String localPath;
  final String? serverId;
  final bool needsUpload;

  bool get isPendingUpload => needsUpload && serverId == null;

  VoucherSheetReceipt copyWith({
    String? localPath,
    String? serverId,
    bool? needsUpload,
  }) {
    return VoucherSheetReceipt(
      localPath: localPath ?? this.localPath,
      serverId: serverId ?? this.serverId,
      needsUpload: needsUpload ?? this.needsUpload,
    );
  }
}

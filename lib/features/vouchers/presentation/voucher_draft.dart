class VoucherDraft {
  const VoucherDraft({
    this.clientId,
    this.projectId,
    this.clientLabel,
    this.kind = 'receive',
    this.expenseType = 'materials',
    this.method = 'cash',
    this.amountPiastres,
    this.itemId,
    this.itemLabel,
    this.supplierId,
    this.supplierLabel,
    this.craftsmanId,
    this.craftsmanLabel,
    this.description,
    this.date,
    this.editingTransactionId,
    this.receiptImagePath,
    this.providerLinkedToClient,
  });

  final String? clientId;
  final String? projectId;
  final String? clientLabel;
  final String kind;
  final String expenseType;
  final String method;
  final int? amountPiastres;
  final String? itemId;
  final String? itemLabel;
  final String? supplierId;
  final String? supplierLabel;
  final String? craftsmanId;
  final String? craftsmanLabel;
  final String? description;
  final DateTime? date;
  final String? editingTransactionId;
  final String? receiptImagePath;

  /// After picking a spend payee: whether client already has an agreement with that provider.
  final bool? providerLinkedToClient;

  VoucherDraft copyWith({
    String? clientId,
    String? projectId,
    String? clientLabel,
    String? kind,
    String? expenseType,
    String? method,
    int? amountPiastres,
    String? itemId,
    String? itemLabel,
    String? supplierId,
    String? supplierLabel,
    String? craftsmanId,
    String? craftsmanLabel,
    String? description,
    DateTime? date,
    String? editingTransactionId,
    String? receiptImagePath,
    bool? providerLinkedToClient,
    bool clearCraftsman = false,
    bool clearSupplier = false,
    bool clearItem = false,
    bool clearProviderLink = false,
  }) {
    return VoucherDraft(
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      clientLabel: clientLabel ?? this.clientLabel,
      kind: kind ?? this.kind,
      expenseType: expenseType ?? this.expenseType,
      method: method ?? this.method,
      amountPiastres: amountPiastres ?? this.amountPiastres,
      itemId: clearItem ? null : (itemId ?? this.itemId),
      itemLabel: clearItem ? null : (itemLabel ?? this.itemLabel),
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      supplierLabel:
          clearSupplier ? null : (supplierLabel ?? this.supplierLabel),
      craftsmanId: clearCraftsman ? null : (craftsmanId ?? this.craftsmanId),
      craftsmanLabel:
          clearCraftsman ? null : (craftsmanLabel ?? this.craftsmanLabel),
      description: description ?? this.description,
      date: date ?? this.date,
      editingTransactionId: editingTransactionId ?? this.editingTransactionId,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      providerLinkedToClient:
          clearProviderLink ? null : (providerLinkedToClient ?? this.providerLinkedToClient),
    );
  }

  static const fresh = VoucherDraft();
}

class VoucherDraft {
  const VoucherDraft({
    this.clientId,
    this.projectId,
    this.kind = 'receive',
    this.expenseType = 'materials',
    this.method = 'cash',
    this.amountPiastres,
    this.itemId,
    this.supplierId,
    this.craftsmanId,
    this.description,
    this.date,
    this.editingTransactionId,
  });

  final String? clientId;
  final String? projectId;
  final String kind;
  final String expenseType;
  final String method;
  final int? amountPiastres;
  final String? itemId;
  final String? supplierId;
  final String? craftsmanId;
  final String? description;
  final DateTime? date;
  final String? editingTransactionId;

  VoucherDraft copyWith({
    String? clientId,
    String? projectId,
    String? kind,
    String? expenseType,
    String? method,
    int? amountPiastres,
    String? itemId,
    String? supplierId,
    String? craftsmanId,
    String? description,
    DateTime? date,
    String? editingTransactionId,
    bool clearCraftsman = false,
    bool clearSupplier = false,
  }) {
    return VoucherDraft(
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      kind: kind ?? this.kind,
      expenseType: expenseType ?? this.expenseType,
      method: method ?? this.method,
      amountPiastres: amountPiastres ?? this.amountPiastres,
      itemId: itemId ?? this.itemId,
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      craftsmanId: clearCraftsman ? null : (craftsmanId ?? this.craftsmanId),
      description: description ?? this.description,
      date: date ?? this.date,
      editingTransactionId: editingTransactionId ?? this.editingTransactionId,
    );
  }

  static const fresh = VoucherDraft();
}

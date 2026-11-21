/// Plain ledger row types (formerly Drift data classes).
library;

class Client {
  const Client({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.phone,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String? phone;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Project {
  const Project({
    required this.id,
    required this.workspaceId,
    required this.clientId,
    required this.name,
    this.unitAddress,
    required this.status,
    this.engineerBasisPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String clientId;
  final String name;
  final String? unitAddress;
  final String status;
  final int? engineerBasisPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Item {
  const Item({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.colorKey,
    required this.iconName,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String colorKey;
  final String iconName;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Supplier {
  const Supplier({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.phone,
    this.notes,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CraftsmenData {
  const CraftsmenData({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.phone,
    this.trade,
    this.notes,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String phone;
  final String? trade;
  final String? notes;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ProjectCraftsmanAgreement {
  const ProjectCraftsmanAgreement({
    required this.id,
    required this.workspaceId,
    required this.projectId,
    required this.craftsmanId,
    this.initialAmountPiastres,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String projectId;
  final String craftsmanId;
  final int? initialAmountPiastres;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.workspaceId,
    required this.projectId,
    required this.kind,
    required this.amountPiastres,
    required this.date,
    required this.method,
    this.description,
    this.receiptImagePath,
    this.itemId,
    this.expenseType,
    this.supplierId,
    this.craftsmanId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String projectId;
  final String kind;
  final int amountPiastres;
  final DateTime date;
  final String method;
  final String? description;
  final String? receiptImagePath;
  final String? itemId;
  final String? expenseType;
  final String? supplierId;
  final String? craftsmanId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

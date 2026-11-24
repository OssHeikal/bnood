class InboxNotificationRecord {
  const InboxNotificationRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.readAt,
    this.officeId,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? officeId;

  bool get isUnread => readAt == null;

  factory InboxNotificationRecord.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    Map<String, dynamic> data = const {};
    if (dataRaw is Map) {
      data = Map<String, dynamic>.from(dataRaw);
    }
    final readAtRaw = json['read_at'];
    return InboxNotificationRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: data,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      readAt: readAtRaw == null
          ? null
          : DateTime.parse(readAtRaw as String).toLocal(),
      officeId: json['office_id'] as String?,
    );
  }

  InboxNotificationRecord markReadLocal() {
    return InboxNotificationRecord(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      createdAt: createdAt,
      readAt: DateTime.now(),
      officeId: officeId,
    );
  }
}

class InboxNotificationsPage {
  const InboxNotificationsPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<InboxNotificationRecord> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}
class AnalyticsUser {
  const AnalyticsUser({
    required this.id,
    this.name,
    this.phone,
  });

  final String id;
  final String? name;
  final String? phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsUser && id == other.id && name == other.name && phone == other.phone;

  @override
  int get hashCode => Object.hash(id, name, phone);
}
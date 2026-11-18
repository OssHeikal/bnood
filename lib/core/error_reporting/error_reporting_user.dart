/// Login identity attached to error reports (not statement contact phone).
class ErrorReportingUser {
  const ErrorReportingUser({
    required this.id,
    required this.phone,
    this.name,
  });

  final String id;
  final String phone;
  final String? name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorReportingUser &&
          id == other.id &&
          phone == other.phone &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, phone, name);
}
class SubscriberUser {
  const SubscriberUser({
    required this.id,
    required this.phone,
    this.phoneVerifiedAt,
  });

  final String id;
  final String phone;
  final DateTime? phoneVerifiedAt;

  factory SubscriberUser.fromJson(Map<String, dynamic> json) {
    final verified = json['phone_verified_at'];
    return SubscriberUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      phoneVerifiedAt: verified is String ? DateTime.tryParse(verified) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriberUser && id == other.id && phone == other.phone;

  @override
  int get hashCode => Object.hash(id, phone);
}

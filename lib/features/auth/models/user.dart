class User {
  const User({
    required this.id,
    required this.phone,
    this.name,
    this.phoneVerifiedAt,
  });

  final String id;
  final String phone;
  final String? name;
  final DateTime? phoneVerifiedAt;

  bool get hasCompleteName {
    final trimmed = name?.trim();
    return trimmed != null && trimmed.isNotEmpty;
  }

  factory User.fromJson(Map<String, dynamic> json) {
      final verified = json['phone_verified_at'];
    final rawName = json['name'];
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: rawName == null ? null : rawName as String,
      phoneVerifiedAt: verified is String ? DateTime.tryParse(verified) : null,
    );
  }

  User copyWith({String? name}) {
    return User(
      id: id,
      phone: phone,
      name: name ?? this.name,
      phoneVerifiedAt: phoneVerifiedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          id == other.id &&
          phone == other.phone &&
          name == other.name &&
          phoneVerifiedAt == other.phoneVerifiedAt;

  @override
  int get hashCode => Object.hash(id, phone, name, phoneVerifiedAt);
}

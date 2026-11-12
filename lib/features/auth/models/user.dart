class User {
  const User({
    required this.id,
    required this.phone,
    this.name,
    this.phoneVerifiedAt,
    this.contactPhone,
    this.logoUrl,
  });

  final String id;
  final String phone;
  final String? name;
  final DateTime? phoneVerifiedAt;
  /// Statement / PDF contact line; null → server uses [phone].
  final String? contactPhone;
  final String? logoUrl;

  bool get hasCompleteName {
    final trimmed = name?.trim();
    return trimmed != null && trimmed.isNotEmpty;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final verified = json['phone_verified_at'];
    final rawName = json['name'];
    final contact = json['contact_phone'];
    final logo = json['logo_url'];
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: rawName as String?,
      phoneVerifiedAt: verified is String ? DateTime.tryParse(verified) : null,
      contactPhone: contact?.toString(),
      logoUrl: logo?.toString(),
    );
  }

  User copyWith({
    String? name,
    String? contactPhone,
    bool clearContactPhone = false,
    String? logoUrl,
    bool clearLogoUrl = false,
  }) {
    return User(
      id: id,
      phone: phone,
      name: name ?? this.name,
      phoneVerifiedAt: phoneVerifiedAt,
      contactPhone: clearContactPhone ? null : (contactPhone ?? this.contactPhone),
      logoUrl: clearLogoUrl ? null : (logoUrl ?? this.logoUrl),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          id == other.id &&
          phone == other.phone &&
          name == other.name &&
          phoneVerifiedAt == other.phoneVerifiedAt &&
          contactPhone == other.contactPhone &&
          logoUrl == other.logoUrl;

  @override
  int get hashCode => Object.hash(id, phone, name, phoneVerifiedAt, contactPhone, logoUrl);
}

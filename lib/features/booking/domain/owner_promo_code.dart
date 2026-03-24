class OwnerPromoCode {
  const OwnerPromoCode({
    required this.id,
    required this.ownerEmail,
    required this.code,
    required this.discountPercent,
    this.usageLimitTotal,
    this.usedCount = 0,
    this.expiresAt,
    this.minHours,
    this.boatScopeIds = const <String>[],
    this.isActive = true,
  });

  final String id;
  final String ownerEmail;
  final String code;
  final double discountPercent;
  final int? usageLimitTotal;
  final int usedCount;
  final DateTime? expiresAt;
  final int? minHours;
  final List<String> boatScopeIds;
  final bool isActive;

  OwnerPromoCode copyWith({
    String? id,
    String? ownerEmail,
    String? code,
    double? discountPercent,
    int? usageLimitTotal,
    int? usedCount,
    DateTime? expiresAt,
    int? minHours,
    List<String>? boatScopeIds,
    bool? isActive,
  }) {
    return OwnerPromoCode(
      id: id ?? this.id,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      code: code ?? this.code,
      discountPercent: discountPercent ?? this.discountPercent,
      usageLimitTotal: usageLimitTotal ?? this.usageLimitTotal,
      usedCount: usedCount ?? this.usedCount,
      expiresAt: expiresAt ?? this.expiresAt,
      minHours: minHours ?? this.minHours,
      boatScopeIds: boatScopeIds ?? this.boatScopeIds,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'ownerEmail': ownerEmail,
        'code': code,
        'discountPercent': discountPercent,
        'usageLimitTotal': usageLimitTotal,
        'usedCount': usedCount,
        'expiresAt': expiresAt?.toIso8601String(),
        'minHours': minHours,
        'boatScopeIds': boatScopeIds,
        'isActive': isActive,
      };

  factory OwnerPromoCode.fromJson(Map<String, dynamic> json) {
    return OwnerPromoCode(
      id: json['id'] as String,
      ownerEmail: json['ownerEmail'] as String,
      code: (json['code'] as String).toUpperCase(),
      discountPercent: (json['discountPercent'] as num).toDouble(),
      usageLimitTotal: json['usageLimitTotal'] as int?,
      usedCount: (json['usedCount'] as int?) ?? 0,
      expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
      minHours: json['minHours'] as int?,
      boatScopeIds: List<String>.from((json['boatScopeIds'] as List<dynamic>? ?? const <dynamic>[])),
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}

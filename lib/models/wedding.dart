class Wedding {
  const Wedding({
    required this.id,
    required this.inviteCode,
    required this.partnerIds,
    required this.weddingDateStart,
    required this.weddingDateEnd,
    required this.guestCount,
    required this.budgetMin,
    required this.budgetMax,
    required this.createdAt,
  });

  final String id;
  final String inviteCode;
  final List<String> partnerIds;
  final DateTime weddingDateStart;
  final DateTime weddingDateEnd;
  final int guestCount;
  final int budgetMin;
  final int budgetMax;
  final DateTime createdAt;

  factory Wedding.fromJson(Map<String, dynamic> json) {
    return Wedding(
      id: json['id'] as String,
      inviteCode: json['inviteCode'] as String,
      partnerIds: (json['partnerIds'] as List).cast<String>(),
      weddingDateStart:
          DateTime.fromMillisecondsSinceEpoch(json['weddingDateStart'] as int),
      weddingDateEnd:
          DateTime.fromMillisecondsSinceEpoch(json['weddingDateEnd'] as int),
      guestCount: (json['guestCount'] as num).toInt(),
      budgetMin: (json['budgetMin'] as num).toInt(),
      budgetMax: (json['budgetMax'] as num).toInt(),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'inviteCode': inviteCode,
        'partnerIds': partnerIds,
        'weddingDateStart': weddingDateStart.millisecondsSinceEpoch,
        'weddingDateEnd': weddingDateEnd.millisecondsSinceEpoch,
        'guestCount': guestCount,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  bool get hasBothPartners => partnerIds.length >= 2;

  Wedding copyWith({
    String? id,
    String? inviteCode,
    List<String>? partnerIds,
    DateTime? weddingDateStart,
    DateTime? weddingDateEnd,
    int? guestCount,
    int? budgetMin,
    int? budgetMax,
    DateTime? createdAt,
  }) {
    return Wedding(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      partnerIds: partnerIds ?? this.partnerIds,
      weddingDateStart: weddingDateStart ?? this.weddingDateStart,
      weddingDateEnd: weddingDateEnd ?? this.weddingDateEnd,
      guestCount: guestCount ?? this.guestCount,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Wedding && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

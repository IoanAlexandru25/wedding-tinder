class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
    this.weddingId,
    this.displayName,
  });

  final String id;
  final String email;
  final String? weddingId;
  final String? displayName;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      weddingId: json['weddingId'] as String?,
      displayName: json['displayName'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (weddingId != null) 'weddingId': weddingId,
        if (displayName != null) 'displayName': displayName,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? weddingId,
    String? displayName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      weddingId: weddingId ?? this.weddingId,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

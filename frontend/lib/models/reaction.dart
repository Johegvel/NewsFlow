class Reaction {
  final int id;
  final int? userId;
  final String kind;
  final String userName;

  Reaction({
    required this.id,
    required this.userId,
    required this.kind,
    required this.userName,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return Reaction(
      id: (json['id'] as num).toInt(),
      userId: json['user_id'] ?? (user is Map ? user['id'] : null),
      kind: json['kind']?.toString() ?? '',
      userName: user is Map ? user['name']?.toString() ?? '' : '',
    );
  }
}

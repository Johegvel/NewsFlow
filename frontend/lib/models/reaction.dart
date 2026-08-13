class Reaction {
  final int id;
  final String kind;
  final String userName;

  Reaction({
    required this.id,
    required this.kind,
    required this.userName,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return Reaction(
      id: json['id'],
      kind: json['kind'] ?? '',
      userName: user['name'] ?? '',
    );
  }
}
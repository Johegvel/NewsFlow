class Interest {
  final int id;
  final String name;
  final String slug;

  Interest({required this.id, required this.name, required this.slug});

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

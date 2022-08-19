class Product {
  final String name;
  final String description;
  final List<dynamic> hostnames;
  final List<dynamic> sources;
  final String icon;
  final String slug;
  final num score; // Implemented by double and int; both of which are used
  final String? parent;
  final List<dynamic> children;
  final dynamic rubric;
  final List<dynamic> updates;
  final String lastUpdated;
  final List<dynamic> contributors;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      description: json['description'],
      hostnames: json['hostnames'],
      sources: json['sources'],
      icon: json['icon'],
      slug: json['slug'],
      score: json['score'],
      parent: json['parent'],
      children: json['children'],
      rubric: json['rubric'],
      updates: json['updates'],
      lastUpdated: json['last_updated'],
      contributors: json['contributors'],
    );
  }
}

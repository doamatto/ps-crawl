class Product {
  final String name;
  final String description;
  final List<dynamic> hostnames;
  final List<dynamic> sources;
  final String icon;
  final String slug;
  final double score;
  final String? parent;
  final List<dynamic> children;
  final dynamic rubric;
  final List<dynamic> updates;
  final String lastUpdated;
  final List<dynamic> contributors;

  Product({
    required this.name,
    required this.description,
    required this.hostnames,
    required this.sources,
    required this.icon,
    required this.slug,
    required this.score,
    required this.parent,
    required this.children,
    required this.rubric,
    required this.updates,
    required this.lastUpdated,
    required this.contributors,
  });

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
      lastUpdated: json['lastUpdated'],
      contributors: json['contributors'],
    );
  }
}

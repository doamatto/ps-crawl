class Contributor {
  final String slug;
  final String? name;
  final String? website;
  final String? github;
  final String? email;
  final String role;

  Contributor({
    required this.slug,
    this.name,
    this.website,
    this.github,
    this.email,
    required this.role,
  });

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(
      slug: json['slug'],
      name: json['name'],
      website: json['website'],
      github: json['github'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class RubricOption {
  final String id;
  final String text;
  final int percent;
  final String? description;

  RubricOption({
    required this.id,
    required this.text,
    required this.percent,
    this.description,
  });

  factory RubricOption.fromJson(Map<String, dynamic> json) {
    return RubricOption(
      id: json['id'],
      text: json['text'],
      percent: json['percent'],
      description: json['description'],
    );
  }
}

class RubricQuestion {
  final String category;
  final String slug;
  final String text;
  final List<dynamic> notes;
  final int points;
  final List<RubricOption> options;

  RubricQuestion({
    required this.category,
    required this.slug,
    required this.text,
    required this.notes,
    required this.points,
    required this.options,
  });

  factory RubricQuestion.fromJson(Map<String, dynamic> json) {
    return RubricQuestion(
      category: json['category'],
      slug: json['slug'],
      text: json['text'],
      notes: json['notes'],
      points: json['points'],
      options: json['options'],
    );
  }
}

class RubricSelection {
  final RubricQuestion question;
  final RubricOption option;
  final List<dynamic> notes;
  final List<dynamic> citations;

  RubricSelection({
    required this.question,
    required this.option,
    required this.notes,
    required this.citations,
  });

  factory RubricSelection.fromJson(Map<String, dynamic> json) {
    return RubricSelection(
      question: json['question'],
      option: json['option'],
      notes: json['notes'],
      citations: json['citations'],
    );
  }
}

class Update {
  final String title;
  final String description;
  final DateTime? date;
  final List<Uri> sources;

  Update({
    required this.title,
    required this.description,
    this.date,
    required this.sources,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      title: json['title'],
      description: json['description'],
      date: json['date'],
      sources: json['sources'],
    );
  }
}

class Product {
  final String name;
  final String description;
  final List<dynamic> hostnames;
  final List<dynamic> sources;
  final String icon;
  final String slug;
  final int score;
  final String? parent;
  final List<Product> children;
  final List<RubricSelection> rubric;
  final List<Update> updates;
  final DateTime lastUpdated;
  final List<Contributor> contributors;

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

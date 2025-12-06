class User {
  final String id;
  final String name;
  final String lastName;
  final int? age;
  final String email;
  final double? height;
  final double? weight;
  final List<String> allergies;
  final List<String> likes;
  final List<String> dislikes;
  final String activityLevel;
  final String? createdByAuthEmail;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    this.age,
    required this.email,
    this.height,
    this.weight,
    required this.allergies,
    required this.likes,
    required this.dislikes,
    required this.activityLevel,
    this.createdByAuthEmail,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      age: json['age'],
      email: json['email'] ?? '',
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      allergies: List<String>.from(json['allergies'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      dislikes: List<String>.from(json['dislikes'] ?? []),
      activityLevel: json['activityLevel'] ?? 'media',
      createdByAuthEmail: json['createdByAuthEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'age': age,
      'email': email,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'likes': likes,
      'dislikes': dislikes,
      'activityLevel': activityLevel,
      'createdByAuthEmail': createdByAuthEmail,
    };
  }
}

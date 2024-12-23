class UserModel {
  final String id;
  final String name;
  final String surname;
  final int age;
  final String schoolName;
  final String city;
  final String email;
  final int diamonds;
  final int points;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.age,
    required this.schoolName,
    required this.city,
    required this.email,
    this.diamonds = 0,
    this.points = 0,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      age: map['age'] ?? 0,
      schoolName: map['schoolName'] ?? '',
      city: map['city'] ?? '',
      email: map['email'] ?? '',
      diamonds: map['diamonds'] ?? 0,
      points: map['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'age': age,
      'schoolName': schoolName,
      'city': city,
      'email': email,
      'diamonds': diamonds,
      'points': points,
    };
  }

  UserModel copyWith({
    String? name,
    String? surname,
    int? age,
    String? schoolName,
    String? city,
    String? email,
    int? diamonds,
    int? points,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
      schoolName: schoolName ?? this.schoolName,
      city: city ?? this.city,
      email: email ?? this.email,
      diamonds: diamonds ?? this.diamonds,
      points: points ?? this.points,
    );
  }
}

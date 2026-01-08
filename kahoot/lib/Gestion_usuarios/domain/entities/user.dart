enum UserType { student, teacher }

extension UserTypeX on UserType {
  String toShortString() => toString().split('.').last;
  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => UserType.student,
    );
  }
}

class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  }); 

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}



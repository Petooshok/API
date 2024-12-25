class UserModel {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String age;
  final String gender;
  final String country;
  final String avatarUrl;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.age,
    required this.gender,
    required this.country,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'age': age,
      'gender': gender,
      'country': country,
      'avatarUrl': avatarUrl,
    };
  }
}

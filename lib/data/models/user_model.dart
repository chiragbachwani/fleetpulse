class UserModel {
  final String id;
  final String email;
  final String name;
  final String password;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    password:json['password'],
    email: json['email'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {
    'password' : password,
    'id': id,
    'email': email,
    'name': name,
  };
}

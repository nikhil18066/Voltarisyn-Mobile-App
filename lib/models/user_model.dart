class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String accountType; // 'home' or 'industry'
  final bool accountTypeLocked;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.accountType = 'home',
    this.accountTypeLocked = true,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? accountType,
    bool? accountTypeLocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      accountType: accountType ?? this.accountType,
      accountTypeLocked: accountTypeLocked ?? this.accountTypeLocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'accountType': accountType,
        'accountTypeLocked': accountTypeLocked,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        accountType: json['accountType'] ?? 'home',
        accountTypeLocked: json['accountTypeLocked'] ?? true,
      );
}

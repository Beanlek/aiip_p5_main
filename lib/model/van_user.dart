class VanUser {
  String id;
  String firstName;
  String lastName;
  String address;
  String email;
  String password;
  String firstRegister;
  String? lastLogin;
  String? updatedAt;
  String? updatedBy;
  String? createdAt;
  String? createdBy;

  VanUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.email,
    required this.password,
    required this.firstRegister,
    required this.lastLogin,
    required this.updatedAt,
    required this.updatedBy,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "address": address,
        "email": email,
        "password": password,
        "first_register": firstRegister,
        "last_login": lastLogin,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
        "created_at": createdAt,
        "created_by": createdBy,
      };

  static VanUser fromJson(Map<String, dynamic> json) => VanUser(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        address: json['address'],
        email: json['email'],
        password: json['password'],
        firstRegister: json['first_register'],
        lastLogin: json['last_login'],
        updatedAt: json['updated_at'],
        updatedBy: json['updated_by'],
        createdAt: json['created_at'],
        createdBy: json['created_by'],
      );
}

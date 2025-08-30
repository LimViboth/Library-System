// To parse this JSON data, do
//
//     final loggedUserModel = loggedUserModelFromJson(jsonString);

import 'dart:convert';

LoggedUserModel loggedUserModelFromJson(String str) => LoggedUserModel.fromJson(json.decode(str));

String loggedUserModelToJson(LoggedUserModel data) => json.encode(data.toJson());

class LoggedUserModel {
    User user;
    String token;

    LoggedUserModel({
        required this.user,
        required this.token,
    });

    factory LoggedUserModel.fromJson(Map<String, dynamic> json) => LoggedUserModel(
        user: User.fromJson(json["user"]),
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "token": token,
    };
}

class User {
    int id;
    String name;
    String email;
    String emailVerifiedAt;
    String createdAt;
    String updatedAt;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.emailVerifiedAt,
        required this.createdAt,
        required this.updatedAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}

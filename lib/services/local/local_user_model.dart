import 'dart:convert';

class LocalUserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime expirationTime;

  LocalUserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.expirationTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'expirationTime': expirationTime.toIso8601String(),
    };
  }

  factory LocalUserModel.fromMap(Map<String, dynamic> map) {
    return LocalUserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      photoUrl: map['photoUrl'] ?? '',
      expirationTime: DateTime.parse(map['expirationTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LocalUserModel.fromJson(String source) => LocalUserModel.fromMap(json.decode(source));
}

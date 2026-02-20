import '../../domain/entities/user.dart';


class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    super.notesCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['idUser'] ?? json['id'] ?? '').toString(),
      username: (json['name'] ?? json['username'] ?? '') as String,
      notesCount: (json['notesCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'notesCount': notesCount,
      };

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      notesCount: user.notesCount,
    );
  }
}

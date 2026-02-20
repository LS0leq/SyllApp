
class User {
  final String id;
  final String username;
  final int notesCount;

  const User({
    required this.id,
    required this.username,
    this.notesCount = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

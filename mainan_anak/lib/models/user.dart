class User {
  final int? id;
  final String username;
  final String passwordHash;
  final String salt;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
    );
  }
}

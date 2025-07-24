class Profile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? title;
  final String? noTelp;
  final String? emailPesan;

  Profile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.title,
    this.noTelp,
    this.emailPesan,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      title: json['title'],
      noTelp: json['no_telp'],
      emailPesan: json['email_pesan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'title': title,
      'no_telp': noTelp,
      'email_pesan': emailPesan,
    };
  }
}

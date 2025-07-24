class Education {
  final String id;
  final String jurusan;
  final String namaTempat;
  final String waktu;
  final String profileId;

  Education({
    required this.id,
    required this.jurusan,
    required this.namaTempat,
    required this.waktu,
    required this.profileId,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      jurusan: json['jurusan'],
      namaTempat: json['nama_tempat'],
      waktu: json['waktu'],
      profileId: json['profile_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jurusan': jurusan,
      'nama_tempat': namaTempat,
      'waktu': waktu,
      'profile_id': profileId,
    };
  }
}

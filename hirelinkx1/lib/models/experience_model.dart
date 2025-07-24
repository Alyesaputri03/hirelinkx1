class Experience {
  final String id;
  final String tempat;
  final String waktu;
  final String jabatan;
  final String wilayah;
  final String profileId;

  Experience({
    required this.id,
    required this.tempat,
    required this.waktu,
    required this.jabatan,
    required this.wilayah,
    required this.profileId,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as String,
      tempat: json['tempat'] as String,
      waktu: json['waktu'] as String,
      jabatan: json['jabatan'] as String,
      wilayah: json['wilayah'] as String,
      profileId: json['profile_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tempat': tempat,
      'waktu': waktu,
      'jabatan': jabatan,
      'wilayah': wilayah,
      'profile_id': profileId,
    };
  }
}

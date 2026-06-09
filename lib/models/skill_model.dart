/// Model representasi data Skill (Keahlian) mahasiswa.
class Skill {
  final int? id;         // ID unik dari database backend
  final String name;     // Nama keahlian (contoh: Flutter, Laravel)
  final double level;    // Persentase tingkat penguasaan (0 - 100)
  final String status;   // Status penguasaan (Beginner, Intermediate, Master)

  Skill({
    this.id,
    required this.name,
    required this.level,
    required this.status,
  });

  /// Membuat instance objek [Skill] dari data JSON (Map).
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      level: (json['level'] as num).toDouble(),
      status: json['status'],
    );
  }

  /// Mengubah objek [Skill] menjadi format JSON (Map) untuk dikirim ke API.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'level': level,
      'status': status,
    };
  }
}


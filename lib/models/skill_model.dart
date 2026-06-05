class Skill {
  final int? id;
  final String name;
  final double level;
  final String status;

  Skill({
    this.id,
    required this.name,
    required this.level,
    required this.status,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      level: (json['level'] as num).toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'level': level,
      'status': status,
    };
  }
}

class StudySchedule {
  final int? id;
  final String title;
  final String? description;
  final int dayOfWeek; // 1=Senin, 2=Selasa, ..., 7=Minggu
  final String startTime; // format "HH:mm"
  final String endTime;   // format "HH:mm"
  final bool isActive;

  StudySchedule({
    this.id,
    required this.title,
    this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory StudySchedule.fromJson(Map<String, dynamic> json) {
    return StudySchedule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
    };
  }

  static String dayName(int day) {
    const days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[day];
  }

  StudySchedule copyWith({
    int? id,
    String? title,
    String? description,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
  }) {
    return StudySchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }
}

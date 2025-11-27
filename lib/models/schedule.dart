class Schedule {
  final int id;
  final String timeIn;
  final String timeOut;
  final String dayOfWeek;
  final Map<String, dynamic> subject;
  final Map<String, dynamic> classroom;
  final Map<String, dynamic> section;
  final Map<String, dynamic> instructor;

  Schedule({
    required this.id,
    required this.timeIn,
    required this.timeOut,
    required this.dayOfWeek,
    required this.subject,
    required this.classroom,
    required this.section,
    required this.instructor,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      timeIn: json['timeIn'] ?? '',
      timeOut: json['timeOut'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      subject: json['subject'] ?? {},
      classroom: json['classroom'] ?? {},
      section: json['section'] ?? {},
      instructor: json['instructor'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeIn': timeIn,
      'timeOut': timeOut,
      'dayOfWeek': dayOfWeek,
      'subject': subject,
      'classroom': classroom,
      'section': section,
      'instructor': instructor,
    };
  }
}

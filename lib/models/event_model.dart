class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dateTime;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dateTime,
  });

  Event copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dateTime,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}

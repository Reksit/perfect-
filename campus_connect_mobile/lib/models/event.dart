class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String organizer;
  final String organizerId;
  final String status;
  final List<String> attendees;
  final int maxAttendees;
  final String eventType;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.organizer,
    required this.organizerId,
    required this.status,
    required this.attendees,
    required this.maxAttendees,
    required this.eventType,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      organizer: json['organizer'] ?? '',
      organizerId: json['organizerId'] ?? '',
      status: json['status'] ?? 'PENDING',
      attendees: (json['attendees'] as List<dynamic>?)
          ?.map((a) => a.toString())
          .toList() ?? [],
      maxAttendees: json['maxAttendees'] ?? 0,
      eventType: json['eventType'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'organizerId': organizerId,
      'status': status,
      'attendees': attendees,
      'maxAttendees': maxAttendees,
      'eventType': eventType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isPast => date.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  int get availableSpots => maxAttendees - attendees.length;
  bool get isFull => attendees.length >= maxAttendees;
}

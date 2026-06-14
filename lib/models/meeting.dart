enum MeetingType { video, audio, consultation }
enum MeetingStatus { upcoming, passed, canceled }

class Meeting {
  final String id;
  final String withUserId;
  final DateTime scheduledAt;
  final MeetingType type;
  final MeetingStatus status;
  final String? notes;

  const Meeting({
    required this.id,
    required this.withUserId,
    required this.scheduledAt,
    required this.type,
    this.status = MeetingStatus.upcoming,
    this.notes,
  });

  Meeting copyWith({MeetingStatus? status}) {
    return Meeting(
      id: id,
      withUserId: withUserId,
      scheduledAt: scheduledAt,
      type: type,
      status: status ?? this.status,
      notes: notes,
    );
  }
}

class TimeSlot {
  final String label;       // e.g. "9:00 AM"
  final bool available;

  const TimeSlot({required this.label, this.available = true});
}

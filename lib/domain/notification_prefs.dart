class NotificationPrefs {
  const NotificationPrefs({
    this.hour = 8,
    this.minute = 0,
    this.fridgeLeadDays = 3,
    this.fridgeOnTheDay = true,
    this.freezerLeadDays = 3,
    this.freezerOnTheDay = true,
    this.pantryEarlyDays = 14,
    this.pantryLateDays = 7,
  });

  static const defaults = NotificationPrefs();

  final int hour;
  final int minute;
  final int fridgeLeadDays;
  final bool fridgeOnTheDay;
  final int freezerLeadDays;
  final bool freezerOnTheDay;
  final int pantryEarlyDays;
  final int pantryLateDays;

  NotificationPrefs copyWith({
    int? hour,
    int? minute,
    int? fridgeLeadDays,
    bool? fridgeOnTheDay,
    int? freezerLeadDays,
    bool? freezerOnTheDay,
    int? pantryEarlyDays,
    int? pantryLateDays,
  }) {
    return NotificationPrefs(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      fridgeLeadDays: fridgeLeadDays ?? this.fridgeLeadDays,
      fridgeOnTheDay: fridgeOnTheDay ?? this.fridgeOnTheDay,
      freezerLeadDays: freezerLeadDays ?? this.freezerLeadDays,
      freezerOnTheDay: freezerOnTheDay ?? this.freezerOnTheDay,
      pantryEarlyDays: pantryEarlyDays ?? this.pantryEarlyDays,
      pantryLateDays: pantryLateDays ?? this.pantryLateDays,
    );
  }
}

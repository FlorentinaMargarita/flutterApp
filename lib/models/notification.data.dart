class NotificationData {
  static const String idField = 'id';
  static const String notificationIdField = 'notificationId';
  static const String hourField = 'hour';
  static const String minuteField = 'minute';

  String id;
  int notificationId;
  int hour;
  int minute;

  NotificationData(this.hour, this.minute);

  NotificationData.fromDb(Map<String, dynamic> json, String id) {
    this.id = id;
    this.notificationId = json[notificationIdField];
    this.hour = json[hourField];
    this.minute = json[minuteField];
  }

  Map<String, dynamic> toJson() {
    return {
      notificationIdField: this.notificationId,
      hourField: this.hour,
      minuteField: this.minute,
    };
  }

  @override
  String toString() {
    return 'notificationId: $notificationId, hour: $hour, minute: $minute';
  }
}

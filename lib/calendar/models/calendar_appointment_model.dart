import 'package:flutter/widgets.dart';

class CalendarAppointment<T> {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final T? extraData;
  final String? customerFullName;
  final Color? cardBackgroundColor;
  final Color? cardTextColor;
  final Function()? onTap;

  CalendarAppointment({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.extraData,
    this.customerFullName,
    this.cardBackgroundColor,
    this.cardTextColor,
    this.onTap,
  });

  @override
  String toString() {
    return 'CalendarAppointment(title: $title, startTime: $startTime, endTime: $endTime, description: $description)';
  }
}

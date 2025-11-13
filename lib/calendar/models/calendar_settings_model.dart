import 'package:flutter/material.dart';

class CalendarSettings {
  final int firstDayOfWeek;
  final TimeOfDay workingHoursStart;
  final TimeOfDay workingHoursEnd;
  final int timeSlotInterval;
  final Color backgroundColor;
  final Color textColor;

  // Metin çevirileri
  final String zoomDialogTitle;
  final String zoomDialogMinButton;
  final String zoomDialogNormalButton;
  final String zoomDialogMaxButton;
  final String zoomDialogOkButton;
  final String zoomTooltip;
  final String closedText;

  CalendarSettings({
    this.firstDayOfWeek = 1,
    this.workingHoursStart = const TimeOfDay(hour: 9, minute: 0),
    this.workingHoursEnd = const TimeOfDay(hour: 17, minute: 0),
    this.timeSlotInterval = 30,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.zoomDialogTitle = 'Takvim Boyutu',
    this.zoomDialogMinButton = 'Min',
    this.zoomDialogNormalButton = 'Normal',
    this.zoomDialogMaxButton = 'Max',
    this.zoomDialogOkButton = 'Tamam',
    this.zoomTooltip = 'Boyutlandır',
    this.closedText = 'Kapalı',
  });
  int getTimeLabelCount() {
    final startMinutes = workingHoursStart.hour * 60 + workingHoursStart.minute;
    final endMinutes = workingHoursEnd.hour * 60 + workingHoursEnd.minute;
    return ((endMinutes - startMinutes) / timeSlotInterval).ceil();
  }

  List<String> getTimeLabels(BuildContext context) {
    List<String> labels = [];
    final totalSlots = getTimeLabelCount();
    for (int i = 0; i <= totalSlots; i++) {
      if (i == (totalSlots - 1)) {
        labels.add(workingHoursEnd.format(context));
        break;
      }
      final totalMinutes = (workingHoursStart.hour * 60 + workingHoursStart.minute) + (i * timeSlotInterval);
      final hour = totalMinutes ~/ 60;
      final minute = totalMinutes % 60;
      final timeLabel = TimeOfDay(hour: hour, minute: minute);
      labels.add(timeLabel.format(context));
    }
    return labels;
  }
}

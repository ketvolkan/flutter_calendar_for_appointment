import 'package:flutter/material.dart';
import 'package:takvim_yeni/calendar/models/calendar_appointment_model.dart';

class CalenderEmployee {
  final String? name;
  final String? surname;
  final Color? overlayColor;
  final String? profileImageUrl;
  final List<CalendarAppointment>? appointments;
  final bool allDayClosed;

  CalenderEmployee({this.name, this.surname, this.overlayColor, this.profileImageUrl, this.appointments, this.allDayClosed = false});
}

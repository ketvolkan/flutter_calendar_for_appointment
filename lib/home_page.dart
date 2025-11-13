import 'dart:math';
import 'package:flutter/material.dart';
import 'calendar/calendar_view.dart';
import 'calendar/models/calendar_appointment_model.dart';
import 'calendar/models/calendar_employee_model.dart';
import 'calendar/models/calendar_settings_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CalenderEmployee> employees = [];

  @override
  void initState() {
    super.initState();
    _generateTestData();
  }

  void _generateTestData() {
    final random = Random(42);

    final serviceNames = [
      'Sac Kesimi',
      'Sakal Tirasi',
      'Cilt Bakimi',
      'Manikur',
      'Pedikur',
      'Masaj',
      'Epilasyon',
      'Kas Tasarimi',
      'Boya',
      'Fon',
      'Keratin',
      'Protez Tirnak',
      'Makyaj',
      'Gelin Paketi',
      'Kalici Oje',
      'Ipek Kirpik',
    ];

    final customerNames = [
      'Ahmet Yilmaz',
      'Mehmet Kaya',
      'Ayse Demir',
      'Fatma Celik',
      'Ali Sahin',
      'Zeynep Ozturk',
      'Hasan Arslan',
      'Emine Aydin',
      'Mustafa Ozdemir',
      'Hatice Yildiz',
      'Ibrahim Koc',
      'Elif Simsek',
      'Omer Gunes',
      'Merve Polat',
      'Huseyin Cetin',
      'Sevgi Acar',
      'Yusuf Turk',
      'Seda Aktas',
      'Burak Dogan',
      'Dilara Karaca',
      'Emre Cakir',
      'Deniz Demirci',
      'Can Ozcan',
      'Ece Yurt',
      'Baris Erdogan',
      'Gamze Kilic',
      'Serkan Aksoy',
      'Pinar Kurt',
    ];

    for (int i = 0; i < 15; i++) {
      final employeeColor = Color.fromRGBO(random.nextInt(156) + 100, random.nextInt(156) + 100, random.nextInt(156) + 100, 1.0);

      final appointmentCount = 6; // Her çalışana 6 randevu
      final List<CalendarAppointment> employeeAppointments = [];

      for (int j = 0; j < appointmentCount; j++) {
        final dayOffset = random.nextInt(7); // 1 hafta içinde
        final baseDate = DateTime.now().add(Duration(days: dayOffset));

        final startHour = 9 + random.nextInt(8);
        final startMinute = random.nextInt(3) * 20; // 0, 20, 40

        final durationMinutes = [30, 45, 60, 90][random.nextInt(4)]; // Daha tutarlı süreler

        final startTime = DateTime(baseDate.year, baseDate.month, baseDate.day, startHour, startMinute);

        final endTime = startTime.add(Duration(minutes: durationMinutes));

        if (endTime.hour < 19) {
          employeeAppointments.add(
            CalendarAppointment(
              title: serviceNames[random.nextInt(serviceNames.length)],
              description: 'Musteri: ${customerNames[random.nextInt(customerNames.length)]}',
              startTime: startTime,
              endTime: endTime,
              customerFullName: customerNames[random.nextInt(customerNames.length)],
              cardBackgroundColor: employeeColor,
              cardTextColor: Colors.white,
            ),
          );
        }
      }

      employees.add(CalenderEmployee(name: 'Calisan', surname: '${i + 1}', overlayColor: employeeColor, appointments: employeeAppointments));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Takvim Demo - 15 Calisan Test'), backgroundColor: Colors.blueGrey),
      body: CalendarView(
        employeeList: employees,
        calendarSettings: CalendarSettings(
          zoomDialogTitle: 'Takvim Boyutu',
          zoomDialogMinButton: 'Min',
          zoomDialogNormalButton: 'Normal',
          zoomDialogMaxButton: 'Max',
          zoomDialogOkButton: 'Tamam',
          zoomTooltip: 'Takvim Boyutu',
          closedText: 'Kapali',
        ),
        onTapCell: (employee, dateTime) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bos Hucre\n'
                'Calisan: ${employee.name} ${employee.surname}\n'
                'Saat: ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

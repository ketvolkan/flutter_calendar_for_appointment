import 'package:flutter/material.dart';
import 'package:takvim_yeni/calendar/models/calendar_appointment_model.dart';
import 'package:takvim_yeni/calendar/models/calendar_employee_model.dart';
import 'package:takvim_yeni/calendar/models/calendar_settings_model.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key, required this.employeeList, required this.calendarSettings, this.onTapCell});
  final List<CalenderEmployee> employeeList;
  final CalendarSettings calendarSettings;
  final void Function(CalenderEmployee employee, DateTime dateTime)? onTapCell;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  double _zoomLevel = 1.0;
  final double _minZoom = 0.3;
  final double _maxZoom = 2.0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _timeScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _hourHeight => (_screenHeight * 0.2 * _zoomLevel).clamp(_screenHeight * 0.01, _screenHeight * 0.15);
  double get _employeeColumnWidth {
    final baseWidth = _screenWidth * 0.2; // Ekranın %20'si
    return (baseWidth * _zoomLevel).clamp(_screenWidth * 0.12, _screenWidth * 0.35);
  }

  // Saat kolonu genişliği
  double get _timeColumnWidth => _screenWidth * 0.08; // Ekranın %8'i (sabit)

  // Header yüksekliği - minimum sınırı azaltıldı
  double get _headerHeight => (_screenHeight * 0.08 * _zoomLevel).clamp(_screenHeight * 0.04, _screenHeight * 0.12);

  @override
  void initState() {
    super.initState();
    // Minimum zoom'u tüm çalışanları sığdıracak şekilde hesapla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMinZoom();
    });

    // Scroll kontrollerini senkronize et
    _horizontalScrollController.addListener(_syncHeaderScroll);
    _scrollController.addListener(_syncTimeScroll);
  }

  void _calculateMinZoom() {
    // Ekran genişliğini al
    final screenWidth = _screenWidth - (_screenWidth * 0.08); // Saat kolonu hariç
    final employeeCount = widget.employeeList.length;

    if (employeeCount > 0) {
      // Her çalışan için gereken minimum genişlik
      final minWidthPerEmployee = _screenWidth * 0.12;
      final requiredWidth = employeeCount * minWidthPerEmployee;

      if (requiredWidth > screenWidth) {
        // Tüm çalışanları sığdırmak için minimum zoom
        final calculatedMinZoom = (screenWidth / employeeCount) / (_screenWidth * 0.2);
        setState(() {
          _zoomLevel = calculatedMinZoom.clamp(_minZoom, 1.0);
        });
      }
    }
  }

  void _syncHeaderScroll() {
    if (_headerScrollController.hasClients && _horizontalScrollController.hasClients) {
      _headerScrollController.jumpTo(_horizontalScrollController.offset);
    }
  }

  void _syncTimeScroll() {
    if (_timeScrollController.hasClients && _scrollController.hasClients) {
      _timeScrollController.jumpTo(_scrollController.offset);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncTimeScroll);
    _scrollController.dispose();
    _timeScrollController.dispose();
    _horizontalScrollController.removeListener(_syncHeaderScroll);
    _horizontalScrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  void _showZoomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.calendarSettings.zoomDialogTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 32),
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _zoomLevel = (_zoomLevel - 0.1).clamp(_minZoom, _maxZoom);
                              });
                            });
                          },
                          tooltip: 'Küçült',
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Text('${(_zoomLevel * 100).toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 32),
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _zoomLevel = (_zoomLevel + 0.1).clamp(_minZoom, _maxZoom);
                              });
                            });
                          },
                          tooltip: 'Büyüt',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Slider(
                      value: _zoomLevel,
                      min: _minZoom,
                      max: _maxZoom,
                      divisions: 50,
                      label: '${(_zoomLevel * 100).toInt()}%',
                      onChanged: (value) {
                        setDialogState(() {
                          setState(() {
                            _zoomLevel = value;
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _zoomLevel = _minZoom;
                              });
                            });
                          },
                          child: Text(widget.calendarSettings.zoomDialogMinButton),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _zoomLevel = 1.0;
                              });
                            });
                          },
                          child: Text(widget.calendarSettings.zoomDialogNormalButton),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              setState(() {
                                _zoomLevel = _maxZoom;
                              });
                            });
                          },
                          child: Text(widget.calendarSettings.zoomDialogMaxButton),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(widget.calendarSettings.zoomDialogOkButton),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> timeLabels = widget.calendarSettings.getTimeLabels(context);

    return Column(
      children: [
        // Başlık satırı (çalışan isimleri)
        _buildHeaderRow(),
        // Takvim içeriği
        Expanded(
          child: Row(
            children: [
              // Sol taraftaki saat etiketleri
              _buildTimeColumn(timeLabels),
              // Takvim grid ve randevular
              Expanded(
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: widget.employeeList.length * _employeeColumnWidth,
                    child: SingleChildScrollView(controller: _scrollController, child: _buildCalendarGrid(timeLabels)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    final fontSize = (_screenWidth * 0.025 * _zoomLevel).clamp(_screenWidth * 0.012, _screenWidth * 0.035);
    final avatarRadius = (_screenWidth * 0.025 * _zoomLevel).clamp(_screenWidth * 0.015, _screenWidth * 0.04);
    final spacing = (_screenWidth * 0.008 * _zoomLevel).clamp(_screenWidth * 0.002, _screenWidth * 0.015);

    return Container(
      height: _headerHeight,
      decoration: BoxDecoration(
        color: widget.calendarSettings.backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
      ),
      child: Row(
        children: [
          // Sol üst köşe - Zoom butonu
          Container(
            width: _timeColumnWidth * 1.4,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
              color: Colors.blue.shade50,
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.search, size: _screenWidth * 0.055),
                onPressed: _showZoomDialog,
                tooltip: widget.calendarSettings.zoomTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Kendi boyutunu kullan
              ),
            ),
          ),
          // Çalışan başlıkları
          Expanded(
            child: SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: widget.employeeList.map((employee) {
                  return Container(
                    width: _employeeColumnWidth,
                    height: _headerHeight,
                    padding: EdgeInsets.symmetric(horizontal: spacing * 0.5),
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
                      color: employee.overlayColor?.withOpacity(0.1) ?? Colors.grey.shade50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (employee.profileImageUrl != null)
                          CircleAvatar(radius: avatarRadius, backgroundImage: NetworkImage(employee.profileImageUrl!))
                        else
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: employee.overlayColor ?? Colors.blue,
                            child: Text(
                              '${employee.name?.substring(0, 1) ?? ''}${employee.surname?.substring(0, 1) ?? ''}',
                              style: TextStyle(color: Colors.white, fontSize: fontSize * 0.8),
                            ),
                          ),
                        SizedBox(height: spacing * 0.5),
                        Flexible(
                          child: Text(
                            '${employee.name ?? ''} ${employee.surname ?? ''}',
                            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: widget.calendarSettings.textColor),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(List<String> timeLabels) {
    final fontSize = (_screenWidth * 0.025 * _zoomLevel).clamp(_screenWidth * 0.010, _screenWidth * 0.035);

    return Container(
      width: _timeColumnWidth * 1.4,
      decoration: BoxDecoration(
        color: widget.calendarSettings.backgroundColor,
        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: ListView.builder(
        controller: _timeScrollController,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: timeLabels.length,
        itemExtent: _hourHeight, // Her item'ın sabit yüksekliği
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Text(
              timeLabels[index],
              style: TextStyle(fontSize: fontSize, color: widget.calendarSettings.textColor, fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(List<String> timeLabels) {
    return SizedBox(
      height: timeLabels.length * _hourHeight,
      child: Stack(
        children: [
          // Grid çizgileri
          _buildGridLines(timeLabels),
          // Randevu kartları
          ..._buildAppointmentCards(),
        ],
      ),
    );
  }

  Widget _buildGridLines(List<String> timeLabels) {
    final fontSize = (_screenWidth * 0.022 * _zoomLevel).clamp(_screenWidth * 0.010, _screenWidth * 0.032);
    final startMinutes = widget.calendarSettings.workingHoursStart.hour * 60 + widget.calendarSettings.workingHoursStart.minute;

    return Row(
      children: widget.employeeList.asMap().entries.map((entry) {
        final employee = entry.value;
        return Container(
          width: _employeeColumnWidth,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
            color: employee.allDayClosed ? Colors.grey.shade200.withOpacity(0.5) : Colors.transparent,
          ),
          child: Column(
            children: List.generate(timeLabels.length, (index) {
              // Her hücrenin zamanını hesapla
              final cellMinutes = startMinutes + (index * widget.calendarSettings.timeSlotInterval);
              final cellHour = cellMinutes ~/ 60;
              final cellMinute = cellMinutes % 60;
              final cellDateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, cellHour, cellMinute);

              return GestureDetector(
                onTap: employee.allDayClosed
                    ? null
                    : () {
                        widget.onTapCell?.call(employee, cellDateTime);
                      },
                child: Container(
                  height: _hourHeight,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                  ),
                  child: employee.allDayClosed
                      ? Center(
                          child: Text(
                            widget.calendarSettings.closedText,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: fontSize),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildAppointmentCards() {
    List<Widget> cards = [];

    final startMinutes = widget.calendarSettings.workingHoursStart.hour * 60 + widget.calendarSettings.workingHoursStart.minute;
    final horizontalMargin = (_screenWidth * 0.004 * _zoomLevel).clamp(1.0, 8.0); // Zoom'a göre responsive margin

    for (int employeeIndex = 0; employeeIndex < widget.employeeList.length; employeeIndex++) {
      final employee = widget.employeeList[employeeIndex];
      final appointments = employee.appointments ?? [];

      // Çakışan randevuları grupla
      final appointmentGroups = _groupOverlappingAppointments(appointments);

      for (var group in appointmentGroups) {
        final groupSize = group.length;

        for (int i = 0; i < groupSize; i++) {
          final appointment = group[i];

          // Randevunun başlangıç ve bitiş saatlerini hesapla
          final appointmentStartMinutes = appointment.startTime.hour * 60 + appointment.startTime.minute;
          final appointmentEndMinutes = appointment.endTime.hour * 60 + appointment.endTime.minute;

          // Randevu süresini hesapla
          final durationMinutes = appointmentEndMinutes - appointmentStartMinutes;

          // Takvim başlangıcına göre pozisyon hesapla
          final topOffset = ((appointmentStartMinutes - startMinutes) / 60) * _hourHeight;
          final height = (durationMinutes / 60) * _hourHeight;

          // Çakışan randevular için genişlik ve sol pozisyonu hesapla
          final totalAvailableWidth = _employeeColumnWidth - (horizontalMargin * 2);
          final cardWidth = totalAvailableWidth / groupSize; // Grup boyutuna göre eşit böl
          final cardGap = (1.0 * _zoomLevel).clamp(0.5, 2.0); // Kartlar arası boşluk
          final leftOffset = (employeeIndex * _employeeColumnWidth) + horizontalMargin + (i * cardWidth);

          cards.add(
            Positioned(
              left: leftOffset,
              top: topOffset,
              width: cardWidth - cardGap,
              height: height,
              child: _buildAppointmentCard(appointment, employee),
            ),
          );
        }
      }
    }

    return cards;
  }

  // Çakışan randevuları grupla
  List<List<CalendarAppointment>> _groupOverlappingAppointments(List<CalendarAppointment> appointments) {
    if (appointments.isEmpty) return [];

    // Randevuları başlangıç zamanına göre sırala
    final sortedAppointments = List<CalendarAppointment>.from(appointments)..sort((a, b) => a.startTime.compareTo(b.startTime));

    List<List<CalendarAppointment>> groups = [];
    List<CalendarAppointment> currentGroup = [sortedAppointments[0]];

    for (int i = 1; i < sortedAppointments.length; i++) {
      final current = sortedAppointments[i];
      bool overlaps = false;

      // Mevcut gruptaki herhangi bir randevu ile çakışıyor mu kontrol et
      for (var appointment in currentGroup) {
        if (_doAppointmentsOverlap(appointment, current)) {
          overlaps = true;
          break;
        }
      }

      if (overlaps) {
        currentGroup.add(current);
      } else {
        groups.add(currentGroup);
        currentGroup = [current];
      }
    }

    groups.add(currentGroup);
    return groups;
  }

  // İki randevunun çakışıp çakışmadığını kontrol et
  bool _doAppointmentsOverlap(CalendarAppointment a, CalendarAppointment b) {
    return a.startTime.isBefore(b.endTime) && a.endTime.isAfter(b.startTime);
  }

  Widget _buildAppointmentCard(CalendarAppointment appointment, CalenderEmployee employee) {
    final cardColor = appointment.cardBackgroundColor ?? employee.overlayColor ?? Colors.blue;
    final textColor = appointment.cardTextColor ?? Colors.white;

    // Randevu süresini hesapla
    final duration = appointment.endTime.difference(appointment.startTime);
    final durationText = '${duration.inMinutes} dk';

    // Ekran boyutuna göre dinamik font boyutları - minimum değerler daha düşük
    final titleFontSize = (_screenWidth * 0.028 * _zoomLevel).clamp(_screenWidth * 0.012, _screenWidth * 0.04);
    final normalFontSize = (_screenWidth * 0.022 * _zoomLevel).clamp(_screenWidth * 0.010, _screenWidth * 0.032);
    final smallFontSize = (_screenWidth * 0.018 * _zoomLevel).clamp(_screenWidth * 0.008, _screenWidth * 0.025);
    final padding = (_screenWidth * 0.012 * _zoomLevel).clamp(_screenWidth * 0.003, _screenWidth * 0.02);
    final spacing = (_screenWidth * 0.004 * _zoomLevel).clamp(_screenWidth * 0.001, _screenWidth * 0.008);
    final verticalMargin = (_screenWidth * 0.002 * _zoomLevel).clamp(0.5, _screenWidth * 0.004);
    final borderWidth = (2 * _zoomLevel).clamp(0.5, 2.0); // Border genişliği zoom'a göre
    final borderRadius = (_screenWidth * 0.015 * _zoomLevel).clamp(_screenWidth * 0.005, _screenWidth * 0.025);

    return GestureDetector(
      onTap: appointment.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: cardColor, width: borderWidth),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4 * _zoomLevel, offset: Offset(0, 2 * _zoomLevel))],
        ),
        child: ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Yükseklik ve genişliği kontrol et
              final height = constraints.maxHeight;
              final width = constraints.maxWidth;
              final isTiny = height < _screenHeight * 0.035; // Çok küçük (<35px)
              final isSmall = height < _screenHeight * 0.055; // Küçük (<55px)
              final isMedium = height < _screenHeight * 0.09; // Orta (<90px)
              final isNarrow = width < _screenWidth * 0.08; // Çok dar (<80px genişlik)

              if (isTiny) {
                // Çok küçük randevular: sadece başlık (tek satır)
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    appointment.title,
                    style: TextStyle(fontSize: smallFontSize * 0.9, fontWeight: FontWeight.bold, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                );
              }

              // Dar kartlar için daha küçük font boyutları
              final adjustedTitleSize = isNarrow ? titleFontSize * 0.85 : titleFontSize;
              final adjustedNormalSize = isNarrow ? normalFontSize * 0.85 : normalFontSize;
              final adjustedSmallSize = isNarrow ? smallFontSize * 0.85 : smallFontSize;

              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık ve süre (her zaman göster)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            appointment.title,
                            style: TextStyle(
                              fontSize: isSmall ? adjustedNormalSize : adjustedTitleSize,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isNarrow) ...[
                          SizedBox(width: spacing),
                          Text(
                            durationText,
                            style: TextStyle(fontSize: adjustedSmallSize, color: textColor.withOpacity(0.8)),
                            overflow: TextOverflow.clip,
                          ),
                        ],
                      ],
                    ),
                    // Müşteri adı (orta ve büyük randevularda göster, dar değilse)
                    if (!isSmall && !isNarrow && appointment.customerFullName != null) ...[
                      SizedBox(height: spacing),
                      Text(
                        appointment.customerFullName!,
                        style: TextStyle(fontSize: adjustedNormalSize, color: textColor.withOpacity(0.9)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Saat aralığı (sadece büyük ve geniş randevularda göster)
                    if (!isMedium && !isNarrow) ...[
                      SizedBox(height: spacing),
                      Text(
                        '${TimeOfDay.fromDateTime(appointment.startTime).format(context)} - ${TimeOfDay.fromDateTime(appointment.endTime).format(context)}',
                        style: TextStyle(fontSize: adjustedSmallSize, color: textColor.withOpacity(0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Açıklama (sadece çok büyük ve geniş randevularda göster)
                    if (!isMedium && !isNarrow && appointment.description.isNotEmpty && height > _screenHeight * 0.12) ...[
                      SizedBox(height: spacing),
                      Text(
                        appointment.description,
                        style: TextStyle(fontSize: adjustedSmallSize, color: textColor.withOpacity(0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

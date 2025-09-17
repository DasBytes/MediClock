import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/storage.dart'; // You'll implement storage in Flutter
import '../../constants/colors.dart'; // Your custom colors

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<Medication> medications = [];
  List<DoseHistory> doseHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final meds = await Storage.getMedications();
      final history = await Storage.getDoseHistory();
      setState(() {
        medications = meds;
        doseHistory = history;
      });
    } catch (e) {
      debugPrint("Error loading calendar data: $e");
    }
  }

  int get daysInMonth =>
      DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

  int get firstDayOfMonth =>
      DateTime(selectedDate.year, selectedDate.month, 1).weekday % 7;

  List<Widget> renderCalendar() {
    List<Widget> calendar = [];
    List<Widget> week = [];

    // Empty slots before month start
    for (int i = 0; i < firstDayOfMonth; i++) {
      week.add(Expanded(child: Container()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date =
          DateTime(selectedDate.year, selectedDate.month, day);
      final isToday = DateTime.now().toString().substring(0, 10) ==
          date.toString().substring(0, 10);

      final hasDoses = doseHistory.any((dose) =>
          DateTime.parse(dose.timestamp).toString().substring(0, 10) ==
          date.toString().substring(0, 10));

      week.add(
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primaryGreen.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "$day",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      color: isToday ? AppColors.primaryGreen : Colors.black,
                    ),
                  ),
                  if (hasDoses)
                    Positioned(
                      bottom: 6,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      if ((firstDayOfMonth + day) % 7 == 0 || day == daysInMonth) {
        calendar.add(Row(children: week));
        week = [];
      }
    }

    return calendar;
  }

  List<Widget> renderMedicationsForDate() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final dayDoses = doseHistory
        .where((dose) =>
            DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(dose.timestamp)) ==
            dateStr)
        .toList();

    return medications.map((med) {
      final taken = dayDoses.any((d) => d.medicationId == med.id && d.taken);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 40,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: med.color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(med.dosage,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(med.times.first,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            taken
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle,
                            size: 20, color: Colors.green),
                        SizedBox(width: 4),
                        Text("Taken",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: med.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await Storage.recordDose(
                          med.id, true, DateTime.now().toIso8601String());
                      loadData();
                    },
                    child: const Text("Take",
                        style: TextStyle(color: Colors.white)),
                  ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: Column(
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left,
                        size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text("Calendar",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => setState(() => selectedDate =
                                  DateTime(selectedDate.year,
                                      selectedDate.month - 1, 1)),
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              DateFormat.yMMMM().format(selectedDate),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              onPressed: () => setState(() => selectedDate =
                                  DateTime(selectedDate.year,
                                      selectedDate.month + 1, 1)),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text("Sun"),
                            Text("Mon"),
                            Text("Tue"),
                            Text("Wed"),
                            Text("Thu"),
                            Text("Fri"),
                            Text("Sat"),
                          ],
                        ),
                        ...renderCalendar(),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMMEEEEd().format(selectedDate),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        ...renderMedicationsForDate(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example model classes (replace with real ones from utils/storage.dart)
class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final Color color;

  Medication(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.times,
      required this.color});
}

class DoseHistory {
  final String medicationId;
  final String timestamp;
  final bool taken;

  DoseHistory(
      {required this.medicationId,
      required this.timestamp,
      required this.taken});
}

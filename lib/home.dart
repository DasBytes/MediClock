import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String color;
  final List<String> times;
  final bool reminderEnabled;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.color,
    required this.times,
    this.reminderEnabled = false,
  });
}

class DoseHistory {
  final String medicationId;
  final bool taken;

  DoseHistory({required this.medicationId, required this.taken});
}

class _HomeScreenState extends State<HomeScreen> {
  List<Medication> todaysMedications = [];
  List<DoseHistory> doseHistory = [];
  bool showNotifications = false;
  int completedDoses = 0;

  @override
  void initState() {
    super.initState();
    loadMedications();
  }

  void loadMedications() {
    // Mock data, replace with actual storage fetch
    setState(() {
      todaysMedications = [
        Medication(
          id: '1',
          name: 'Paracetamol',
          dosage: '500mg',
          color: '#4CAF50',
          times: ['08:00 AM'],
        ),
        Medication(
          id: '2',
          name: 'Vitamin C',
          dosage: '1000mg',
          color: '#FF9800',
          times: ['09:00 AM'],
        ),
      ];
      doseHistory = [
        DoseHistory(medicationId: '1', taken: true),
        DoseHistory(medicationId: '2', taken: false),
      ];
      completedDoses = doseHistory.where((d) => d.taken).length;
    });
  }

  bool isDoseTaken(String medId) {
    return doseHistory.any((dose) => dose.medicationId == medId && dose.taken);
  }

  double get progress =>
      todaysMedications.isEmpty ? 0 : completedDoses / (todaysMedications.length * 2);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a8e2d), Color(0xFF146922)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Daily Progress',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () => setState(() => showNotifications = true),
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            if (todaysMedications.isNotEmpty)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${todaysMedications.length}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: width * 0.55,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: width * 0.55,
                            height: width * 0.55,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 15,
                              backgroundColor: Colors.white24,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                '$completedDoses of ${todaysMedications.length * 2} doses',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white70),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _quickActionButton(
                        width,
                        'Add\nMedication',
                        Icons.add_circle_outline,
                        const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      _quickActionButton(
                        width,
                        'Calendar\nView',
                        Icons.calendar_today_outlined,
                        const [Color(0xFF2196F3), Color(0xFF1976D2)],
                      ),
                      _quickActionButton(
                        width,
                        'History\nLog',
                        Icons.history,
                        const [Color(0xFFE91E63), Color(0xFFC2185B)],
                      ),
                      _quickActionButton(
                        width,
                        'Refill\nTracker',
                        Icons.medical_services_outlined,
                        const [Color(0xFFFF5722), Color(0xFFE64A19)],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Schedule",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See All',
                          style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  todaysMedications.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const Icon(Icons.medical_services,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 10),
                              const Text(
                                'No medications scheduled for today',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Add Medication'),
                              )
                            ],
                          ),
                        )
                      : Column(
                          children: todaysMedications.map((med) {
                            final taken = isDoseTaken(med.id);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Color(int.parse(med.color.replaceAll('#', '0xff'))).withOpacity(0.2),
                                  child: Icon(Icons.medical_services,
                                      color: Color(
                                          int.parse(med.color.replaceAll('#', '0xff')))),
                                ),
                                title: Text(med.name),
                                subtitle: Text(med.dosage),
                                trailing: taken
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.check_circle,
                                              color: Color(0xFF4CAF50)),
                                          SizedBox(width: 4),
                                          Text('Taken',
                                              style: TextStyle(
                                                  color: Color(0xFF4CAF50))),
                                        ],
                                      )
                                    : ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(int.parse(
                                                med.color.replaceAll('#', '0xff')))),
                                        child: const Text('Take'),
                                      ),
                              ),
                            );
                          }).toList(),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(
      double width, String label, IconData icon, List<Color> gradient) {
    return Container(
      width: (width - 52) / 2,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: gradient),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

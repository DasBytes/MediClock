import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/storage.dart'; // Implement storage in Flutter
import '../../constants/colors.dart'; // Your colors like primaryGreen

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<EnrichedDoseHistory> history = [];
  String selectedFilter = "all"; // "all", "taken", "missed"

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final doseHistory = await Storage.getDoseHistory();
      final medications = await Storage.getMedications();

      final enrichedHistory = doseHistory.map((dose) {
        final med = medications.firstWhere(
            (m) => m.id == dose.medicationId,
            orElse: () => Medication(
                  id: 'unknown',
                  name: 'Unknown Medication',
                  dosage: '',
                  times: [''],
                  color: Colors.grey,
                ));
        return EnrichedDoseHistory(
            id: dose.id,
            medicationId: dose.medicationId,
            timestamp: dose.timestamp,
            taken: dose.taken,
            medication: med);
      }).toList();

      setState(() => history = enrichedHistory);
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Map<String, List<EnrichedDoseHistory>> groupHistoryByDate() {
    Map<String, List<EnrichedDoseHistory>> grouped = {};
    for (var dose in history) {
      final dateStr = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(dose.timestamp));
      grouped.putIfAbsent(dateStr, () => []);
      grouped[dateStr]!.add(dose);
    }
    // Sort descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  List<EnrichedDoseHistory> get filteredHistory {
    return history.where((dose) {
      if (selectedFilter == "all") return true;
      if (selectedFilter == "taken") return dose.taken;
      if (selectedFilter == "missed") return !dose.taken;
      return true;
    }).toList();
  }

  Future<void> handleClearAllData() async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Clear All Data'),
              content: const Text(
                  'Are you sure you want to clear all medication data? This action cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear All', style: TextStyle(color: Colors.red))),
              ],
            ));

    if (confirm == true) {
      try {
        await Storage.clearAllData();
        await loadHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data has been cleared successfully')),
        );
      } catch (e) {
        debugPrint('Error clearing data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to clear data. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedHistory = groupHistoryByDate();

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
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text('History Log',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xfff8f9fa),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterButton('All', 'all'),
                  filterButton('Taken', 'taken'),
                  filterButton('Missed', 'missed'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...groupedHistory.entries.map((entry) {
                  final date = DateTime.parse(entry.key);
                  final doses = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(date),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ...doses.map((dose) => historyCard(dose)),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: handleClearAllData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFEBEE),
                      foregroundColor: const Color(0xffFF5252),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xffFFCDD2)),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear All Data',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget filterButton(String label, String value) {
    final active = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primaryGreen : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey[600]),
        ),
      ),
    );
  }

  Widget historyCard(EnrichedDoseHistory dose) {
    final med = dose.medication!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            margin: const EdgeInsets.only(right: 16),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(med.dosage,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(DateFormat.jm().format(DateTime.parse(dose.timestamp)),
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: dose.taken ? const Color(0xffE8F5E9) : const Color(0xffFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  dose.taken ? Icons.check_circle : Icons.close,
                  size: 16,
                  color: dose.taken ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  dose.taken ? "Taken" : "Missed",
                  style: TextStyle(
                    color: dose.taken ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Models

class EnrichedDoseHistory {
  final String id;
  final String medicationId;
  final String timestamp;
  final bool taken;
  final Medication? medication;

  EnrichedDoseHistory({
    required this.id,
    required this.medicationId,
    required this.timestamp,
    required this.taken,
    this.medication,
  });
}

// Medication model (replace with your storage.dart implementation)
class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final Color color;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.color,
  });
}

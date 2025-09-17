import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String color;
  int currentSupply;
  final int totalSupply;
  final int refillAt;
  String? lastRefillDate;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.color,
    required this.currentSupply,
    required this.totalSupply,
    required this.refillAt,
    this.lastRefillDate,
  });
}

class RefillTrackerScreen extends StatefulWidget {
  const RefillTrackerScreen({Key? key}) : super(key: key);

  @override
  _RefillTrackerScreenState createState() => _RefillTrackerScreenState();
}

class _RefillTrackerScreenState extends State<RefillTrackerScreen> {
  List<Medication> medications = [];

  @override
  void initState() {
    super.initState();
    loadMedications();
  }

  void loadMedications() {
    // Simulate loading medications
    setState(() {
      medications = [
        Medication(
          id: '1',
          name: 'Aspirin',
          dosage: '500mg',
          color: '#4CAF50',
          currentSupply: 30,
          totalSupply: 60,
          refillAt: 30,
          lastRefillDate: '2025-09-10',
        ),
        Medication(
          id: '2',
          name: 'Vitamin C',
          dosage: '1000mg',
          color: '#2196F3',
          currentSupply: 10,
          totalSupply: 20,
          refillAt: 50,
        ),
      ];
    });
  }

  void handleRefill(Medication med) {
    setState(() {
      med.currentSupply = med.totalSupply;
      med.lastRefillDate = DateTime.now().toIso8601String();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${med.name} has been refilled to ${med.totalSupply} units.'),
      ),
    );
  }

  Map<String, dynamic> getSupplyStatus(Medication med) {
    double percentage = (med.currentSupply / med.totalSupply) * 100;
    if (percentage <= med.refillAt) {
      return {'status': 'Low', 'color': Colors.red, 'bgColor': Color(0xFFFFEBEE)};
    } else if (percentage <= 50) {
      return {'status': 'Medium', 'color': Colors.orange, 'bgColor': Color(0xFFFFF3E0)};
    } else {
      return {'status': 'Good', 'color': Colors.green, 'bgColor': Color(0xFFE8F5E9)};
    }
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A8E2D), Color(0xFF146922)],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            padding: EdgeInsets.only(left: 20, right: 20, top: 40),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Color(0xFF1A8E2D)),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Refill Tracker',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: medications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            'No medications to track',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to add medication
                            },
                            child: Text('Add Medication'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1A8E2D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        final med = medications[index];
                        final supplyStatus = getSupplyStatus(med);
                        final percentage =
                            (med.currentSupply / med.totalSupply) * 100;

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                          margin: EdgeInsets.only(bottom: 16, top: 16),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: hexToColor(med.color),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      margin: EdgeInsets.only(right: 16),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(med.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16)),
                                          Text(med.dosage,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: supplyStatus['bgColor'],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        supplyStatus['status'],
                                        style: TextStyle(
                                          color: supplyStatus['color'],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Supply info
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Current Supply',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14)),
                                        Text('${med.currentSupply} units',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: percentage / 100,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: supplyStatus['color'],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text('${percentage.round()}%',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600])),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text('Refill at: ${med.refillAt}%',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                                if (med.lastRefillDate != null)
                                  Text(
                                      'Last refill: ${DateFormat.yMd().format(DateTime.parse(med.lastRefillDate!))}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600])),
                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: percentage < 100
                                      ? () => handleRefill(med)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: percentage < 100
                                        ? hexToColor(med.color)
                                        : Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    minimumSize: Size(double.infinity, 40),
                                  ),
                                  child: Text('Record Refill',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

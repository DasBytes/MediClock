import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({Key? key}) : super(key: key);

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _currentSupplyController = TextEditingController();
  final TextEditingController _refillAtController = TextEditingController();

  DateTime _startDate = DateTime.now();
  bool _reminderEnabled = true;
  bool _refillReminder = false;

  String _selectedFrequency = "Once daily";
  String _selectedDuration = "7 days";

  List<String> frequencies = [
    "Once daily",
    "Twice daily",
    "Three times daily",
    "Four times daily",
    "As needed"
  ];

  List<String> durations = [
    "7 days",
    "14 days",
    "30 days",
    "90 days",
    "Ongoing"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A8E2D), Color(0xFF146922)],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    "New Medication",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medication Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Medication Name",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Medication name required" : null,
                      ),
                      SizedBox(height: 12),

                      // Dosage
                      TextFormField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          labelText: "Dosage (e.g., 500mg)",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Dosage required" : null,
                      ),
                      SizedBox(height: 20),

                      // Frequency
                      Text("How often?", style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: frequencies.map((freq) {
                          bool selected = _selectedFrequency == freq;
                          return ChoiceChip(
                            label: Text(freq),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedFrequency = freq;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),

                      // Duration
                      Text("For how long?", style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: durations.map((dur) {
                          bool selected = _selectedDuration == dur;
                          return ChoiceChip(
                            label: Text(dur),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedDuration = dur;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),

                      // Start Date
                      Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _startDate = picked);
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Color(0xFF1A8E2D)),
                              SizedBox(width: 10),
                              Text(DateFormat.yMd().format(_startDate)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Reminder Switch
                      SwitchListTile(
                        title: Text("Reminders"),
                        subtitle: Text("Get notified when it's time to take your medication"),
                        value: _reminderEnabled,
                        onChanged: (val) => setState(() => _reminderEnabled = val),
                      ),
                      SizedBox(height: 10),

                      // Refill Tracking
                      SwitchListTile(
                        title: Text("Refill Tracking"),
                        subtitle: Text("Get notified when you need to refill"),
                        value: _refillReminder,
                        onChanged: (val) => setState(() => _refillReminder = val),
                      ),
                      if (_refillReminder)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _currentSupplyController,
                                decoration: InputDecoration(
                                  labelText: "Current Supply",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _refillAtController,
                                decoration: InputDecoration(
                                  labelText: "Alert At",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 20),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: "Notes",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        maxLines: 4,
                      ),

                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Save medication logic
                                }
                              },
                              child: Text("Add Medication"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

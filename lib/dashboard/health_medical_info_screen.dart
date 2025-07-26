import 'package:flutter/material.dart';

class HealthAndMedicalInfoScreen extends StatefulWidget {
  const HealthAndMedicalInfoScreen({super.key});

  @override
  State<HealthAndMedicalInfoScreen> createState() =>
      _HealthAndMedicalInfoScreenState();
}

class _HealthAndMedicalInfoScreenState
    extends State<HealthAndMedicalInfoScreen> {
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();

  // Initial data
  String weight = '60 kg';
  String chronicConditions = 'Nothing';
  String allergies = 'No';
  String examDate = '2023-02-25';
  String vaccination = 'Hepatities and Covid';

  // Controllers for editing
  late TextEditingController weightController;
  late TextEditingController chronicController;
  late TextEditingController allergiesController;
  late TextEditingController examDateController;
  late TextEditingController vaccinationController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(text: weight);
    chronicController = TextEditingController(text: chronicConditions);
    allergiesController = TextEditingController(text: allergies);
    examDateController = TextEditingController(text: examDate);
    vaccinationController = TextEditingController(text: vaccination);
  }

  @override
  void dispose() {
    weightController.dispose();
    chronicController.dispose();
    allergiesController.dispose();
    examDateController.dispose();
    vaccinationController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        weight = weightController.text;
        chronicConditions = chronicController.text;
        allergies = allergiesController.text;
        examDate = examDateController.text;
        vaccination = vaccinationController.text;
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5), // 🌸 Light Pink Background
      appBar: AppBar(
        title: const Text('Health & Medical Info'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: toggleEdit,
            tooltip: isEditing ? 'Cancel' : 'Edit',
          )
        ],
      ),
      body: Column(
        children: [
          _buildHeaderCard(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildField('Weight', weightController, weight, Icons.monitor_weight),
                  _buildField('Chronic Conditions', chronicController, chronicConditions, Icons.healing),
                  _buildField('Allergies', allergiesController, allergies, Icons.bug_report),
                  _buildField('Last Physical Exam Date', examDateController, examDate, Icons.calendar_today),
                  _buildField('Vaccination History', vaccinationController, vaccination, Icons.vaccines),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: saveForm,
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.redAccent, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: const [
          Icon(Icons.favorite, size: 48, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your vital health data is secure and helps ensure you’re ready to donate safely.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String title,
    TextEditingController controller,
    String displayValue,
    IconData icon,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          isEditing
              ? TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF9F9F9),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter $title' : null,
                )
              : Text(displayValue,
                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}

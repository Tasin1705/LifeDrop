import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.redAccent,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.pink.shade50,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.redAccent),
                    title: Text("Full Name"),
                    subtitle: Text("Ahnaf Tahmid"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.male, color: Colors.redAccent),
                    title: Text("Gender"),
                    subtitle: Text("Male"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.redAccent),
                    title: Text("Date of Birth"),
                    subtitle: Text("05-02-2002"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.redAccent),
                    title: Text("Phone Number"),
                    subtitle: Text("01976889988"),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.redAccent),
                    title: Text("Address"),
                    subtitle: Text("Mirpur Cantonment"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

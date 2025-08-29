import 'package:flutter/material.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 2,
        title: const Text(
          'Hospital Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.red),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const HospitalProfileDialog(),
                );
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HospitalOverviewTab(),
          DonationRequestsTab(),
          DonorsRecordTab(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bloodtype),
            label: 'Requests',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Donor's Record",
            backgroundColor: Colors.red,
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

class HospitalOverviewTab extends StatelessWidget {
  const HospitalOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade600, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Welcome back, City Hospital!\nManage blood donations and requests efficiently.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DashboardCard(
              icon: Icons.bloodtype,
              value: '15',
              label: 'Active Requests',
              color: Colors.red.shade100,
            ),
            _DashboardCard(
              icon: Icons.people,
              value: '250',
              label: 'Donors Available',
              color: Colors.blue.shade100,
            ),
            _DashboardCard(
              icon: Icons.check_circle,
              value: '120',
              label: 'Completed',
              color: Colors.green.shade100,
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Recent Blood Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _RequestCard(
          bloodType: 'A+',
          units: '4',
          urgency: 'Medium',
          status: 'Active',
          date: '2025-07-25',
          donors: '2 donors responded',
          statusColor: const Color.fromARGB(255, 255, 0, 0),
        ),

        _RequestCard(
          bloodType: 'O+',
          units: '2',
          urgency: 'High',
          status: 'Active',
          date: '2025-07-18',
          donors: '3 donors responded',
          statusColor: const Color.fromARGB(255, 255, 0, 0),
        ),

        _RequestCard(
          bloodType: 'A+',
          units: '2',
          urgency: 'Low',
          status: 'Active',
          date: '2025-07-18',
          donors: '3 donors responded',
          statusColor: const Color.fromARGB(255, 255, 0, 0),
        ),
        const SizedBox(height: 12),
        _RequestCard(
          bloodType: 'O-',
          units: '1',
          urgency: 'Medium',
          status: 'Completed',
          date: '2025-07-16',
          donors: '1 donor completed',
          statusColor: Colors.green,
        ),
      ],
    );
  }
}

class DonationRequestsTab extends StatelessWidget {
  const DonationRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Blood Requests',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const NewBloodRequestDialog(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Request'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _RequestCard(
          bloodType: 'A+',
          units: '2',
          urgency: 'High',
          status: 'Active',
          date: '2025-07-18',
          donors: '3 donors responded',
          statusColor: const Color.fromARGB(255, 255, 0, 0),
          showActions: true,
        ),
        const SizedBox(height: 12),
        _RequestCard(
          bloodType: 'B-',
          units: '1',
          urgency: 'Low',
          status: 'Active',
          date: '2025-07-17',
          donors: '1 donor responded',
          statusColor: const Color.fromARGB(255, 255, 0, 0),
          showActions: true,
        ),
        const SizedBox(height: 24),
        _RequestCard(
          bloodType: 'A-',
          units: '4',
          urgency: 'High',
          status: 'Active',
          date: '2025-12-02',
          donors: '1 donors responded',
          statusColor: const Color.fromARGB(255, 245, 32, 4),
          showActions: true,
        ),
        const SizedBox(height: 24),
        _RequestCard(
          bloodType: 'O+',
          units: '3',
          urgency: 'Low',
          status: 'Active',
          date: '2025-08-01',
          donors: '5 donors responded',
          statusColor: const Color.fromARGB(255, 248, 5, 5),
          showActions: true,
        ),
      ],
    );
  }
}

class HospitalProfileTab extends StatelessWidget {
  const HospitalProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.red,
            child: Icon(Icons.local_hospital, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'City Hospital',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),
        _ProfileInfoCard(
          title: 'Hospital Information',
          items: [
            {'License No': 'HC123456'},
            {'Address': '123 Medical Center St'},
            {'Contact': '+1 234 567 890'},
            {'Email': 'info@cityhospital.com'},
          ],
        ),
        const SizedBox(height: 16),
        _ProfileInfoCard(
          title: 'Statistics',
          items: [
            {'Total Requests': '150'},
            {'Successful Donations': '120'},
            {'Active Donors': '250'},
            {'Average Response Time': '2 hours'},
          ],
        ),
        const SizedBox(height: 32),
        // Add Logout Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to homepage and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DonorRecordCard extends StatelessWidget {
  final String name;
  final String bloodType;
  final String lastDonation;
  final String totalDonations;
  final String contact;
  final String address;

  const _DonorRecordCard({
    required this.name,
    required this.bloodType,
    required this.lastDonation,
    required this.totalDonations,
    required this.contact,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.red.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Blood Type: $bloodType'),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Total Donations: $totalDonations'),
            Text('Last Donation: $lastDonation'),
            Text('Contact: $contact'),
            Text('Address: $address'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Implement call functionality
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Implement message functionality
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewBloodRequestDialog extends StatefulWidget {
  const NewBloodRequestDialog({super.key});

  @override
  State<NewBloodRequestDialog> createState() => _NewBloodRequestDialogState();
}

class _NewBloodRequestDialogState extends State<NewBloodRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  String? selectedBloodType = 'A+';
  String? selectedUrgency = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Blood Request',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBloodType,
                decoration: const InputDecoration(labelText: 'Blood Type'),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedBloodType = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Units Required',
                  suffixText: 'units',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUrgency,
                decoration: const InputDecoration(labelText: 'Urgency Level'),
                items: ['Low', 'Medium', 'High']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedUrgency = value),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        // TODO: Implement request creation
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Create Request'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HospitalProfileDialog extends StatelessWidget {
  const HospitalProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.red,
              child: Icon(Icons.local_hospital, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'City Hospital',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _ProfileInfoCard(
              title: 'Hospital Information',
              items: [
                {'License No': 'HC123456'},
                {'Address': '123 Medical Center St'},
                {'Contact': '+1 234 567 890'},
                {'Email': 'info@cityhospital.com'},
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add new donors record tab
class DonorsRecordTab extends StatelessWidget {
  const DonorsRecordTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search donors...',
            prefixIcon: Icon(Icons.search, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade200),
            ),
            filled: true,
            fillColor: Colors.red.shade50,
          ),
        ),
        const SizedBox(height: 24),
        _DonorRecordCard(
          name: 'John Doe',
          bloodType: 'A+',
          lastDonation: '2025-07-15',
          totalDonations: '5',
          contact: '+1 234-567-890',
          address: '123 Main St, City',
        ),
        const SizedBox(height: 12),
        _DonorRecordCard(
          name: 'Jane Smith',
          bloodType: 'O-',
          lastDonation: '2025-06-20',
          totalDonations: '3',
          contact: '+1 234-567-891',
          address: '456 Oak Ave, City',
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.red),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.red.shade900),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String bloodType;
  final String units;
  final String urgency;
  final String status;
  final String date;
  final String donors;
  final Color statusColor;
  final bool showActions;

  const _RequestCard({
    required this.bloodType,
    required this.units,
    required this.urgency,
    required this.status,
    required this.date,
    required this.donors,
    required this.statusColor,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.red.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Text(
                    bloodType,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$units units',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Urgency: $urgency',
                      style: TextStyle(
                        color: urgency == 'High'
                            ? Colors.red
                            : urgency == 'Medium'
                            ? Colors.orange
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                Icon(Icons.people, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(donors, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DonorListDialog(
                          bloodType: bloodType,
                          requestDate: date,
                        ),
                      );
                    },
                    icon: const Icon(Icons.people, color: Colors.red),
                    label: const Text('View Donors'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement mark as completed
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marked as completed'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DonorListDialog extends StatelessWidget {
  final String bloodType;
  final String requestDate;

  const DonorListDialog({
    super.key,
    required this.bloodType,
    required this.requestDate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Donors - $bloodType',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text('Request Date: $requestDate'),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _DonorListItem(
                    name: 'John Doe',
                    age: '28',
                    bloodType: bloodType,
                    distance: '2.5 km',
                    lastDonation: '2025-05-15',
                  ),
                  _DonorListItem(
                    name: 'Jane Smith',
                    age: '32',
                    bloodType: bloodType,
                    distance: '3.1 km',
                    lastDonation: '2025-06-20',
                  ),
                  _DonorListItem(
                    name: 'Mike Johnson',
                    age: '25',
                    bloodType: bloodType,
                    distance: '1.8 km',
                    lastDonation: '2025-04-10',
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

class _DonorListItem extends StatelessWidget {
  final String name;
  final String age;
  final String bloodType;
  final String distance;
  final String lastDonation;

  const _DonorListItem({
    required this.name,
    required this.age,
    required this.bloodType,
    required this.distance,
    required this.lastDonation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: $age | Blood Type: $bloodType'),
            Text('Last Donation: $lastDonation'),
            Text('Distance: $distance'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: Implement contact donor functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request sent to donor'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Contact', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const _ProfileInfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.red.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.keys.first,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      item.values.first,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

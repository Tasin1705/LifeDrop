import 'package:first_app/blood_request/blood_request_form.dart';
import 'package:flutter/material.dart';

class HospitalDashboard extends StatelessWidget {
  const HospitalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: const [
            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
                Tab(icon: Icon(Icons.bloodtype), text: 'Donation Requests'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
              ],
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  HospitalOverviewTab(),
                  DonationRequestsTab(),
                  HospitalProfileTab(),
                ],
              ),
            ),
          ],
        ),
     floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BloodRequestForm(userType: 'hospital'),
      ),
    );
  },
  backgroundColor: Colors.red,
  tooltip: 'Request for Blood',
  child: const Icon(Icons.add),
),
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
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(12),
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
          units: '2',
          urgency: 'High',
          status: 'Active',
          date: '2025-07-18',
          donors: '3 donors responded',
          statusColor: Colors.orange,
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
      ]
      ,
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
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
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
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
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bloodType,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(date),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Units needed: $units'),
                    Text('Urgency: $urgency'),
                    Text(donors),
                  ],
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            if (showActions) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                 // Update the TextButton in the _RequestCard class
TextButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => DonorListDialog(
        bloodType: bloodType,
        requestDate: date,
      ),
    );
  },
  child: const Text('View Donors'),
),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement cancel request action
                    },
                    child: const Text('Cancel Request'),
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
          child: const Text(
            'Contact',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const _ProfileInfoCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
                )),
          ],
        ),
      ),
    );
  }
}
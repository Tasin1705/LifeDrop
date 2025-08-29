import 'package:flutter/material.dart';
import 'package:first_app/dashboard/schedule_tab.dart';
import 'package:first_app/dashboard/history_tab2.dart';
import 'package:first_app/dashboard/profile_tab.dart';
import 'package:first_app/dashboard/overview_tab.dart';
import 'package:first_app/blood_request/blood_request_form.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.favorite), text: 'Overview'),
                  Tab(icon: Icon(Icons.calendar_today), text: 'Schedule'),
                  Tab(icon: Icon(Icons.history), text: 'History'),
                  Tab(icon: Icon(Icons.person), text: 'Profile'),
                ],
                indicatorColor: Colors.red,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.black,
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    OverviewTab(),
                    ScheduleTab(),
                    HistoryTab(),
                    ProfileTab(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ Floating Action Button to request blood
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          icon: const Icon(Icons.bloodtype),
          label: const Text(
            'Request Blood',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BloodRequestForm(userType: 'donor'),
              ),
            );
          },
        ),
      ),
    );
  }
}

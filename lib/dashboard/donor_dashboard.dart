import 'package:flutter/material.dart';
import 'package:first_app/dashboard/schedule_tab.dart';
import 'package:first_app/dashboard/history_tab.dart';
import 'package:first_app/dashboard/profile_tab.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: const [
              TabBar(
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
              Expanded(
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
      ),
    );
  }
}

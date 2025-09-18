import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule_tab.dart';
import 'history_tab2.dart';
import 'profile_tab.dart';
import 'overview_tab.dart';
import '../blood_request/blood_request_form.dart';
import '../homepage/home_page.dart';  // Import HomePage for the logout redirection
import '../screens/notifications_screen.dart';
import '../services/notification_service.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _selectedIndex = 0;
  bool _drawerOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _pages = [
    const OverviewTab(),
    const ScheduleTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  final List<Map<String, dynamic>> _navigationItems = [
    {'icon': Icons.favorite, 'title': 'Overview'},
    {'icon': Icons.calendar_today, 'title': 'Schedule'},
    {'icon': Icons.history, 'title': 'History'},
    {'icon': Icons.person, 'title': 'Profile'},
  ];

  void _onSelectNav(int index) {
    setState(() {
      _selectedIndex = index;
      _drawerOpen = false;
    });
  }

  Stream<int> _getUnreadNotificationCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);
    
    return NotificationService.getUserNotifications(user.uid).map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['isRead'] == false;
      }).length;
    }).handleError((error) {
      print('Error getting notification count: $error');
      return 0; // Return 0 on error
    });
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Just spacing at the top
          const SizedBox(height: 40),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? Colors.white : Colors.red,
                    ),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _onSelectNav(index);
                      if (isDrawer) Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),

          // Request Blood Button
          Container(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.bloodtype),
                label: const Text(
                  'Find Emergency Blood',
                  style: TextStyle(fontWeight: FontWeight.w600),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            setState(() {
              _drawerOpen = !_drawerOpen;  // Open or close drawer
            });
            if (!isLargeScreen) {
              _scaffoldKey.currentState?.openDrawer();
            }
          },
        ),
        actions: [
          // Notification bell
          StreamBuilder<int>(
            stream: _getUnreadNotificationCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Logout button at the top right
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ],
      ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              child: _buildSidebar(isDrawer: true),
            ),
      body: isLargeScreen
          ? Row(
              children: [
                _buildSidebar(),
                // Main Content Area
                Expanded(
                  child: Container(
                    color: Colors.grey.shade50,
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            )
          : _pages[_selectedIndex],
    );
  }
}

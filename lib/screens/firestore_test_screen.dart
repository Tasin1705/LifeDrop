import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  String _testResult = 'Not tested yet';
  bool _isLoading = false;

  Future<void> _testFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _testResult = 'ERROR: User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Test 1: Try to read user document
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          _testResult += '\n✅ User document read: SUCCESS';
        } else {
          _testResult += '\n⚠️ User document not found';
        }
      } catch (e) {
        _testResult += '\n❌ User document read: FAILED - $e';
      }

      // Test 2: Try to read notifications (simple query)
      try {
        final notificationsQuery = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .limit(5)
            .get();
        
        _testResult += '\n✅ Notifications read (simple): SUCCESS (${notificationsQuery.docs.length} docs)';
      } catch (e) {
        _testResult += '\n❌ Notifications read (simple): FAILED - $e';
      }

      // Test 2b: Try to read notifications with ordering (may require index)
      try {
        final notificationsOrderedQuery = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(5)
            .get();
        
        _testResult += '\n✅ Notifications read (ordered): SUCCESS (${notificationsOrderedQuery.docs.length} docs)';
      } catch (e) {
        if (e.toString().contains('requires an index')) {
          _testResult += '\n⚠️ Notifications read (ordered): INDEX REQUIRED';
          _testResult += '\n   This is expected - the app works without this index';
        } else {
          _testResult += '\n❌ Notifications read (ordered): FAILED - $e';
        }
      }

      // Test 3: Try to create a test notification
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': user.uid,
          'title': 'Test Notification',
          'message': 'This is a test notification',
          'type': 'test',
          'isRead': false,
          'createdAt': Timestamp.now(),
        });
        
        _testResult += '\n✅ Notification create: SUCCESS';
      } catch (e) {
        _testResult += '\n❌ Notification create: FAILED - $e';
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _testResult = 'ERROR: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current User:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FirebaseAuth.instance.currentUser?.uid ?? 'Not authenticated',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'No email',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFirestoreConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Testing...'),
                      ],
                    )
                  : const Text('Test Firestore Connection'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _testResult,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ If you see permission-denied errors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Go to Firebase Console\n'
                      '2. Open Firestore Database\n'
                      '3. Click "Rules" tab\n'
                      '4. Apply the rules from firestore.rules file\n'
                      '5. Click "Publish"',
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String studentName = "";
  int streak = 0;
  int points = 0;
  int nextMilestone = 500;
  List<Map<String, dynamic>> recommendations = [];
  Set<String> studiedResources = {}; // Tracks resources marked as studied
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentDetailsAndRecommendations();
  }

  Future<void> _loadStudentDetailsAndRecommendations() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final studentId = currentUser.uid;

      // Fetch student details from Firestore
      DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
          await _firestore.collection('students').doc(studentId).get();

      if (!studentSnapshot.exists) throw Exception("Student not found.");

      final data = studentSnapshot.data();

      setState(() {
        studentName = "${data?['firstName']} ${data?['lastName']}";
        streak = data?['streak'] ?? 0;
        points = data?['points'] ?? 0;
        nextMilestone = data?['nextMilestone'] ?? 500;

        // Fetch recommendations
        recommendations = (data?['recommendations']?['resources'] ?? [])
            .map<Map<String, dynamic>>((rec) => Map<String, dynamic>.from(rec))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      print("Error loading student details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markAsStudied(String resourceTitle) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final studentId = currentUser.uid;

      // Update points in Firestore
      final studentRef = _firestore.collection('students').doc(studentId);
      await studentRef.update({
        'points':
            FieldValue.increment(10), // Add 10 points per studied resource
      });

      setState(() {
        points += 10; // Update local state
        studiedResources.add(resourceTitle); // Mark resource as studied
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'You marked "$resourceTitle" as studied and earned 10 points!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Error marking as studied: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to mark as studied. Try again later.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open the link.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        elevation: 0,
        title: Text(
          "Welcome back, $studentName! 🎉",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Notifications logic
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile and Streak Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/avater.png'),
                              backgroundColor: Color(0xFF6A5AE0),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "🔥 Streak: $streak Days",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress & Rewards Section
                    const Text(
                      "Progress & Rewards",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF29293E),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Next Milestone: $nextMilestone Points",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: points / nextMilestone,
                            backgroundColor: Colors.white12,
                            color: const Color(0xFF6A5AE0),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$points/$nextMilestone Points Earned",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recommendations Section
                    const Text(
                      "Recommended Resources",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    recommendations.isEmpty
                        ? const Center(
                            child: Text(
                              "No recommendations available.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recommendations.length,
                            itemBuilder: (context, index) {
                              final rec = recommendations[index];
                              final isStudied =
                                  studiedResources.contains(rec['title']);
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFF29293E),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec['title'] ?? "Unknown Title",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      rec['description'] ??
                                          "No description available",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _openLink(rec['link']);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF6A5AE0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            "Open Resource",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: isStudied
                                              ? null
                                              : () {
                                                  _markAsStudied(rec['title']);
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isStudied
                                                ? Colors.grey
                                                : Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            isStudied
                                                ? "Studied"
                                                : "Mark as Studied",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentorHomePage extends StatefulWidget {
  const MentorHomePage({super.key});

  @override
  _MentorHomePageState createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String mentorName = "";
  List<Map<String, dynamic>> mentees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentorDetailsAndMentees();
  }

  Future<void> _loadMentorDetailsAndMentees() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Simulate fetching mentor details
      mentorName = "Dr. John Doe"; // Hardcoded mentor name

      // Hardcode middle school and high school mentees
      setState(() {
        mentees = [
          {'name': 'Alice Johnson', 'level': 'Middle School'},
          {'name': 'Bob Smith', 'level': 'High School'},
          {'name': 'Clara Wilson', 'level': 'Middle School'},
          {'name': 'David Brown', 'level': 'High School'},
        ];
        isLoading = false;
      });
    } catch (e) {
      print("Error loading mentor details and mentees: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addMentee() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        String? selectedLevel;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Mentee Name",
                  filled: true,
                  fillColor: Color(0xFF29293E),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                onChanged: (value) => setState(() => selectedLevel = value),
                items: const [
                  DropdownMenuItem(
                    value: 'Middle School',
                    child: Text('Middle School'),
                  ),
                  DropdownMenuItem(
                    value: 'High School',
                    child: Text('High School'),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: "Select Level",
                  filled: true,
                  fillColor: Color(0xFF29293E),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF29293E),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final menteeName = nameController.text.trim();
                  if (menteeName.isNotEmpty && selectedLevel != null) {
                    setState(() {
                      mentees.add({
                        'name': menteeName,
                        'level': selectedLevel,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add Mentee"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text(
          "Mentor Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, $mentorName! Welcome to your dashboard!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : mentees.isEmpty
                    ? const Center(
                        child: Text(
                          "No mentees assigned yet.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: mentees.length,
                          itemBuilder: (context, index) {
                            final mentee = mentees[index];
                            return Card(
                              color: const Color(0xFF29293E),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  mentee['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  mentee['level'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMentee,
              child: const Text("Add Mentee"),
            ),
          ],
        ),
      ),
    );
  }
}

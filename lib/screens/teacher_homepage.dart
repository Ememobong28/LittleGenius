import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String teacherId;
  String teacherName = "";
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  String classCode = "";

  @override
  void initState() {
    super.initState();
    _loadTeacherDetailsAndStudents();
  }

  Future<void> _loadTeacherDetailsAndStudents() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      teacherId = currentUser.uid;

      // Fetch teacher details from Firestore
      DocumentSnapshot<Map<String, dynamic>> teacherSnapshot =
          await _firestore.collection('teachers').doc(teacherId).get();

      if (!teacherSnapshot.exists) throw Exception("Teacher not found.");

      final data = teacherSnapshot.data();
      final firstName = data?['firstName'] ?? "Unknown";
      final lastName = data?['lastName'] ?? "Teacher";
      teacherName = "$firstName $lastName";

      final teacherCode = data?['code'];
      if (teacherCode == null) throw Exception("Teacher code not found.");

      // Store the teacher's class code
      setState(() {
        teacherName = "$firstName $lastName";
        classCode = teacherCode;
      });

      // Fetch students from the server
      final response = await http.get(
        Uri.parse(
            'https://wesmart-af8a83b2dfb0.herokuapp.com/students?teacherCode=$teacherCode'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final List<dynamic> studentData = decodedResponse['students'];

        setState(() {
          students = studentData.map((student) {
            return (student as Map<String, dynamic>);
          }).toList();

          students.sort((a, b) {
            final aCreatedAt = DateTime.parse(a['createdAt']);
            final bCreatedAt = DateTime.parse(b['createdAt']);
            return bCreatedAt.compareTo(aCreatedAt);
          });

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error loading students: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _generateRecommendations(String studentId, String review) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://wesmart-af8a83b2dfb0.herokuapp.com/generate-material'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'review': review,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
            "Recommendations saved successfully: ${responseData['recommendations']}");

        // Update the student list with recommendations
        setState(() {
          final student = students.firstWhere((s) => s['id'] == studentId);
          student['recommendations'] = responseData['recommendations'];
        });
      } else {
        throw Exception(
            'Failed to generate recommendations: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error generating recommendations: $e");
    }
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    TextEditingController feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFF1E1E2C), // Set background to match theme
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              "${student['firstName']} ${student['lastName']}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                labelText: "Enter Feedback",
                filled: true,
                fillColor: const Color(0xFF29293E), // Blackish background
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelStyle: const TextStyle(color: Colors.white70),
              ),
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _generateRecommendations(
                    student['id'], feedbackController.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5AE0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Generate Recommendations",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text(
          "Teacher Dashboard",
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
              "Hi, $teacherName! Welcome to your dashboard!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Little Rock Central High School",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Class: Grade 3",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF29293E),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  "Class Code",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  classCode.isEmpty ? "Loading class code..." : classCode,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(
                        child: Text(
                          "No students connected yet.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              color: const Color(0xFF29293E),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  "${student['firstName']} ${student['lastName']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  "Grade: ${student['grade'] ?? 'Not Set'}\nCourses: ${student['courses']?.join(', ') ?? 'Grade 3 Math, Reading'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color(0xFF6A5AE0)),
                                  onPressed: () => _showStudentDetails(student),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

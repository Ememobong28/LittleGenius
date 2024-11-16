import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String teacherId;
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      teacherId = currentUser.uid;

      // Fetch the teacher's code from Firestore
      DocumentSnapshot<Map<String, dynamic>> teacherSnapshot =
          await _firestore.collection('teachers').doc(teacherId).get();

      if (!teacherSnapshot.exists) throw Exception("Teacher not found.");

      final teacherCode = teacherSnapshot.data()?['code'];
      if (teacherCode == null) throw Exception("Teacher code not found.");

      final studentSnapshot = await _firestore
          .collection('students')
          .where('teacherCode', isEqualTo: teacherCode)
          .get();

      setState(() {
        students = studentSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading students: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addFeedback(String studentId, String feedback) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .update({'feedback': feedback});
  }

  Future<void> _addCourse(String studentId, String course) async {
    final studentRef = _firestore.collection('students').doc(studentId);

    final studentData = await studentRef.get();
    List<String> courses = List.from(studentData.data()?['courses'] ?? []);
    if (!courses.contains(course)) courses.add(course);

    await studentRef.update({'courses': courses});
  }

  Future<void> _setGrade(String studentId, String grade) async {
    await _firestore
        .collection('students')
        .doc(studentId)
        .update({'grade': grade});
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    TextEditingController feedbackController =
        TextEditingController(text: student['feedback'] ?? '');
    TextEditingController courseController = TextEditingController();
    TextEditingController gradeController =
        TextEditingController(text: student['grade'] ?? '');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
              decoration: const InputDecoration(
                labelText: "Feedback",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _addFeedback(student['id'], feedbackController.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A5AE0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Update Feedback"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: "Add Course",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _addCourse(student['id'], courseController.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Add Course"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(
                labelText: "Grade",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _setGrade(student['id'], gradeController.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Set Grade"),
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
                                  "Grade: ${student['grade'] ?? 'Not Set'}\nCourses: ${student['courses']?.join(', ') ?? 'None'}",
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

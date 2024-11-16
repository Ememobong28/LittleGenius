import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import './login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _codeController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedGrade;
  bool isLoading = false;

  Future<void> teacherSignup() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final classCode = _generateCode();

      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'Teacher',
        'code': classCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(role: 'Teacher'),
        ),
      );
    } catch (e) {
      _showErrorDialog("Teacher Signup Failed", e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> studentSignup() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('students').doc(userId).set({
        'student_id': userId,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'Student',
        'teacherCode': _codeController.text.trim(),
        'grade': selectedGrade,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final teacherSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('code', isEqualTo: _codeController.text.trim())
          .get();

      if (teacherSnapshot.docs.isEmpty) {
        throw Exception('Invalid Teacher Code');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(role: 'Student'),
        ),
      );
    } catch (e) {
      _showErrorDialog("Student Signup Failed", e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _generateCode({int length = 6}) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark purple background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFFB682E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1,
                        color: Colors.white,
                        size: 80,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Signup as ${widget.role}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Get started with WeSmart today!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Form Section
                Container(
                  width: 400, // Fixed width for text fields
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _firstNameController,
                        label: "First Name",
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _lastNameController,
                        label: "Last Name",
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _emailController,
                        label: "Email Address",
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true,
                      ),
                      if (widget.role == 'Student') ...[
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _codeController,
                          label: "Teacher's Code",
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: selectedGrade,
                          decoration: InputDecoration(
                            labelText: "Select Grade",
                            filled: true,
                            fillColor: Colors.white12,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Kindergarten',
                              child: Text("Kindergarten"),
                            ),
                            for (var grade in [
                              '1',
                              '2',
                              '3',
                              '4',
                              '5',
                              '6',
                              '7',
                              '8',
                              '9',
                              '10',
                              '11',
                              '12'
                            ])
                              DropdownMenuItem(
                                value: grade,
                                child: Text("Grade $grade"),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedGrade = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Signup Button
                isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () {
                          widget.role == 'Student'
                              ? studentSignup()
                              : teacherSignup();
                        },
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Signup",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // Footer Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(role: widget.role),
                      ),
                    );
                  },
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      color: Color(0xFF6A5AE0),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

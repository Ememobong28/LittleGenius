import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import './screens/onboarding.dart';
import './screens/signup_screen.dart';
import './screens/teacher_homepage.dart';
import './screens/student_homepage.dart';
import './screens/landing_page.dart';

final firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyC-SI8yu2ZBW74iFGOZwW9lb82gS8Ij5ms",
  authDomain: "wesmart-bf8ac.firebaseapp.com",
  projectId: "wesmart-bf8ac",
  storageBucket: "wesmart-bf8ac.appspot.com",
  messagingSenderId: "457859335618",
  appId: "1:457859335618:web:6dd3355dfca06a5d46825b",
  measurementId: "G-7ZQ3D224BS",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeSmart',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignupScreen(role: 'Student'),
        '/teacher-home': (context) => const TeacherHomePage(),
        '/student-home': (context) => const StudentHomePage(),
      },
    );
  }
}

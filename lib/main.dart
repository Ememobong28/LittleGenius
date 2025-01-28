import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import './screens/onboarding.dart';
import './screens/signup_screen.dart';
import './screens/teacher_homepage.dart';
import './screens/student_homepage.dart';
import './screens/landing_page.dart';
import './screens/mentor_homepage.dart';
import 'dart:html' as html;

final firebaseConfig = const FirebaseOptions(
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LittleGenius',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      navigatorObservers: [MyRouteObserver()],
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignupScreen(role: 'Student'),
        '/teacher-home': (context) => const TeacherHomePage(),
        '/student-home': (context) => const StudentHomePage(),
        '/mentor-home': (context) => const MentorHomePage(),
      },
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateTitle(route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _updateTitle(previousRoute?.settings.name);
  }

  void _updateTitle(String? routeName) {
    String newTitle = 'Little Genius'; // Default title
    switch (routeName) {
      case '/':
        newTitle = 'Little Genius - Home';
        break;
      case '/onboarding':
        newTitle = 'Little Genius - Onboarding';
        break;
      case '/signup':
        newTitle = 'Little Genius - Sign Up';
        break;
      case '/teacher-home':
        newTitle = 'Little Genius - Teacher Dashboard';
        break;
      case '/student-home':
        newTitle = 'Little Genius - Student Dashboard';
        break;
      case '/mentor-home':
        newTitle = 'Little Genius - Mentor Dashboard';
        break;
    }
    html.document.title = newTitle;
  }
}

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101020), // Dark background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AE0), Color(0xFFB682E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: constraints.maxWidth > 768
                          ? Row(
                              children: [
                                // Text Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Unlock Your Potential with Little Genius",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "An AI-driven platform empowering K-6 students in Arkansas with personalized learning, mentorship, and progress tracking.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/onboarding');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFA726),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 24),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "Get Started",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Illustration Section
                                Image.asset(
                                  'assets/image copy.png',
                                  height: 350,
                                  width: 350,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Image.asset(
                                  'assets/image copy.png',
                                  height: 250,
                                  width: 250,
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Unlock Your Potential with Little Genius",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "An AI-driven platform empowering K-12 students in Arkansas with personalized learning, mentorship, and progress tracking.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/onboarding');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFA726),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Get Started",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
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
                const SizedBox(height: 40),

                // Why Choose Us Section
                const Text(
                  "Why Choose Little Genius?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 768) {
                      // Larger screens
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeatureCard(
                            title: "Personalized Learning",
                            description:
                                "AI-driven tools tailored to your needs.",
                            icon: Icons.school,
                            color: Colors.purple,
                          ),
                          _buildFeatureCard(
                            title: "Expert Mentorship",
                            description: "Guidance from trusted educators.",
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _buildFeatureCard(
                            title: "Track Progress",
                            description: "Monitor academic growth over time.",
                            icon: Icons.bar_chart,
                            color: Colors.green,
                          ),
                        ],
                      );
                    } else {
                      // Smaller screens
                      return Wrap(
                        spacing: 16.0, // Horizontal space between cards
                        runSpacing: 16.0, // Vertical space between rows
                        children: [
                          SizedBox(
                            width: constraints.maxWidth / 2 -
                                20, // Adjust width for wrapping
                            child: _buildFeatureCard(
                              title: "Personalized Learning",
                              description:
                                  "AI-driven tools tailored to your needs.",
                              icon: Icons.school,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth / 2 - 20,
                            child: _buildFeatureCard(
                              title: "Expert Mentorship",
                              description: "Guidance from trusted educators.",
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: constraints.maxWidth / 2 - 20,
                            child: _buildFeatureCard(
                              title: "Track Progress",
                              description: "Monitor academic growth over time.",
                              icon: Icons.bar_chart,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// onboarding_screen.dart
import 'package:firebase_auth101/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth101/screens/welcome_screen.dart'; // Adjust import path

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "JUDI ONLINE MERUGIKAN",
      "description": "Hampir 90% pemain judi online mengalami kerugian finansial yang signifikan. Hanya sedikit yang bisa untung, dan itu biasanya hanya sementara sebelum akhirnya kalah lebih banyak.",
      "icon": Icons.money_off,
      "color": Colors.red,
      "image": "💸",
    },
    {
      "title": "KETERGANTUNGAN YANG MEMATIKAN",
      "description": "Judi online dirancang untuk membuat pemain ketagihan. Mekanisme reward yang tidak menentu membuat otak terus mencari sensasi menang, menyebabkan ketergantungan psikologis yang sulit dihentikan.",
      "icon": Icons.warning,
      "color": Colors.orange,
      "image": "🧠",
    },
    {
      "title": "PENGHANCUR KEHIDUPAN",
      "description": "Dampak judi tidak hanya finansial, tetapi juga menghancurkan hubungan keluarga, karir, dan kesehatan mental. Banyak kasus berakhir dengan depresi, hutang menumpuk, bahkan bunuh diri.",
      "icon": Icons.health_and_safety,
      "color": Colors.deepPurple,
      "image": "🚫",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingShown', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            _buildProgressIndicator(),
            _buildNavigationButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data["image"],
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 30),
          Icon(
            data["icon"],
            size: 50,
            color: data["color"],
          ),
          const SizedBox(height: 20),
          Text(
            data["title"],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: data["color"].withOpacity(0.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            data["description"],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.red : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              _completeOnboarding();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              "LEWATI",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == _onboardingData.length - 1) {
                _completeOnboarding();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == _onboardingData.length - 1 ? "MASUK" : "LANJUT",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
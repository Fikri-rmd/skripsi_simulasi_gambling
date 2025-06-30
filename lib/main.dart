import 'package:firebase_auth/firebase_auth.dart';
import 'package:simulasi_slot/firebase_options.dart';
import 'package:simulasi_slot/screens/login_screen.dart';
import 'package:simulasi_slot/screens/onboarding_screen.dart';
import 'package:simulasi_slot/screens/slot_game_screen.dart';
import 'package:simulasi_slot/utils/game_logic.dart';
// import 'package:firebase_auth101/test_slot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GameLogic.settings = await GameSettings.loadFromPrefs();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'slot game',
      theme: ThemeData(
        textTheme: GoogleFonts.urbanistTextTheme(), 
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: Colors.red),
      ),
      home: FutureBuilder(
        future: _checkOnboardingStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final bool onboardingShown = snapshot.data ?? false;
            if (!onboardingShown) {
              return const OnboardingScreen();
            } else {
              return StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return const SlotGameScreen();
                  } else {
                    return const LoginScreen();
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingShown') ?? false;
  }
}
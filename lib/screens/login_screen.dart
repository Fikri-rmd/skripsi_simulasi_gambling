import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth101/slot/test_slot.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Warna merah lebih gelap
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header dengan ikon peringatan
                const Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.yellow,
                    size: 80,
                  ),
                ),
                
                // Pesan peringatan utama
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "PERINGATAN!\nBAHAYA JUDI ONLINE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                ),

                // Konten edukasi
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Aplikasi ini merupakan SIMULASI EDUKASI untuk menunjukkan:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildBulletPoint("🎰 Cara kerja algoritma judi online"),
                      _buildBulletPoint("📉 Manipulasi peluang kemenangan"),
                      _buildBulletPoint("💸 Risiko kerugian finansial"),
                      _buildBulletPoint("🧠 Dampak kecanduan judi"),
                    ],
                  ),
                ),

                // Pesan penegasan
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Judi online adalah aktivitas ILEGAL dan merusak!\nGunakan hanya sebagai media pembelajaran",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.yellow[200],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Bagian login
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        "Masuk dengan Google untuk memulai simulasi edukasi:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: IconButton(
                          icon: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.google,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Login dengan Google",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await FirebaseAuthService().logininwithgoogle();
                            if (FirebaseAuth.instance.currentUser != null) {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SlotGameScreen()),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Disclaimer
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    "Simulasi ini TIDAK MELIBATKAN UANG ASLI\n"
                    "dan BUKAN SARANA PERJUDIAN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  // Widget untuk bullet point
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
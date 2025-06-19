import 'package:firebase_auth101/screens/login_screen.dart';
import 'package:firebase_auth101/slot/test_slot.dart';
import 'package:firebase_auth101/widgets/customized_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade100,
              Colors.red.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade200,
                          Colors.red.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(Icons.warning_amber,
                      size: 100, color: Colors.white),
                ],
              ),
              const SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "WASPADA!\n",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade900,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: "BAHAYA JUDI ONLINE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildInfoCard(
                icon: Icons.attach_money,
                title: "Kerugian Finansial",
                subtitle: "Rata-rata korban kehilangan Rp 25 juta/bulan",
              ),
              _buildInfoCard(
                icon: Icons.health_and_safety,
                title: "Gangguan Mental",
                subtitle: "Tingkat depresi meningkat 65% pada penjudi",
              ),
              const Spacer(),
              CustomizedButton(
                buttonText: "Lanjut",
                buttonColor: Colors.red,
                textColor: Colors.white,
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade600,
                    Colors.red.shade800
                  ],
                ),
                elevation: 6,
                borderRadius: 25,
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                borderColor: Colors.transparent,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
              const SizedBox(height: 15),
              CustomizedButton(
                buttonText: "LIHAT SIMULASI",
                buttonColor: Colors.white,
                textColor: Colors.black,
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50
                  ],
                ),
                elevation: 4,
                borderRadius: 25,
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                borderColor: Colors.grey.shade300,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SlotGameScreen()));
                },
              ),
              const SizedBox(height: 30),
              Text(
                "Data berdasarkan laporan Kemenkumham 2023",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade400, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade800,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
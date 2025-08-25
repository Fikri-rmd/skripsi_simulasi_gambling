import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GetHelpPage extends StatelessWidget {
  const GetHelpPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Jangan Ragu Mencari Bantuan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Jika Anda atau seseorang yang Anda kenal berjuang dengan kecanduan judi, bantuan profesional tersedia dan dapat dijangkau.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          HelpTile(
            title: 'Hotline Kesehatan Jiwa Kemenkes',
            subtitle: 'Hubungi untuk darurat psikologis',
            icon: Icons.phone,
            onTap: () => _launchURL('tel:119'),
          ),
          HelpTile(
            title: 'Aduan Konten Kominfo',
            subtitle: 'Laporkan situs judi online ilegal',
            icon: Icons.report,
            onTap: () => _launchURL('https://aduankonten.id/'),
          ),
          HelpTile(
            title: 'Puskesmas Terdekat',
            subtitle: 'Cari layanan konseling psikologi dasar',
            icon: Icons.local_hospital,
            onTap: () => _launchURL('https://www.google.com/maps/search/puskesmas/'),
          ),
        ],
      ),
    );
  }
}

class HelpTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const HelpTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../data/article_data.dart'; 
import '../widgets/education_card.dart';
import '../widgets/section_title.dart';
import '../widgets/video_card.dart';

class EducationCenterPage extends StatelessWidget {
  const EducationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> videoData = [
      {'id': 'PpU1Rxqka5s','title': 'Bukan Hanya Adiksi yang Membuat Sulit Berhenti Judi ! | Research & Explained','channel': 'Ferry Irwandi',},
      {'id': 'MPh7HymZufQ','title': 'Solusi Efektif & Realistis Meredam Judi Online','channel': 'Ferry Irwandi',},
      {'id': 'sjkU1cSq900','title': 'Tangan Kotor Influencer dalam Judi Online','channel': 'Ferry Irwandi',},
      {'id': 'UbdzEsJCB8A','title': 'Malaka Cinematic Podcast: RS Untuk Pecandu Judol','channel': 'MALAKA',},
      {'id': 'yMBMEBc0a9s','title': 'Kesalahan "Matematika" para Penjudi Eps 2','channel': 'Ferry Irwandi',},
      {'id': 'imr4OIjLi6I','title': 'Menang Judi adalah sebuah ilusi, Feat Ferry Irwandi | Conspiracy N Chill','channel': 'Majelis Lucu',},
      {'id': 'qr9BpA0OlXw','title': 'MASA DEPAN INDONESIA DIHANCURKAN JUDOL','channel': 'MALAKA',},
      {'id': 'FgKV4IT4vHU','title': 'Menghitung Kerugian Sebenarnya dari Judi Online | Jerome Polin','channel': 'MALAKA',},
      {'id': 'lvGTw-n857c','title': 'Judi Online Itu Penipuan: Menang Sesaat, Hancur Selamanya | Reality Bites','channel': 'Narasi Newsroom',},
      {'id': 'OOZ4BWgyxH4','title': 'KECANDUAN JUDI ONLINE MERUBAH HIDUP LO ‼️ Motivasi Berhenti Judi Online','channel': 'Banyak bahas|Fauzi AK',},
      {'id': 'WFWPvJ9IFT8','title': 'Bahaya Judi Slot - Animasi Edukasi','channel': 'Dolewak',},
      {'id': 'X1ePrz3gev8','title': 'PROGRAMER BONGKAR SETTINGAN JUDI ONLINE!! KALIAN SEMUA DITIPU','channel': 'Imam Budi',},
      {'id': 'i_TaURhBTc0','title': 'TONTON SEBELUM DIHAPUS?! BONGKAR SETTINGAN JUDOL HIDUP GAK BAHAGIA JADI TOBAT','channel': 'RJL 5-Fajar Aditya',},
      {'id': '18RBa9o5AfY','title': 'Video Ilustrasi Stop Judi Online','channel': 'KemKomdigi TV',},
      {'id': 'IVa1kenHS3E','title': 'STOP JUDI ONLINE UNTUK MASA DEPAN LEBIH BAIK| IKLAN LAYANAN MASYARAKAT','channel': 'investortrustid',},
      {'id': '_aRuZxYOUBA','title': 'Stop Judi Online','channel': 'Cerdas Berkarakter Kemendikdasmen RI',},
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Pusat Edukasi Anti Judi Online',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...educationArticles.map((article) => EducationCard(article: article)),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Galeri Video Edukasi'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videoData.length,
            itemBuilder: (context, index) {
              final video = videoData[index];
              return VideoCard(
                videoId: video['id']!,
                title: video['title']!,
                channel: video['channel']!,
              );
            },
          ),
        ],
      ),
    );
  }
}
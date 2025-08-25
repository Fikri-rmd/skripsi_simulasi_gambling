import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../screens/article_screen.dart';

class EducationCard extends StatelessWidget {
  final Article article;

  const EducationCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(article.icon, color: Colors.blueGrey, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.article_outlined,
                      color: Colors.black38, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.summary,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Sumber: ${article.sourceName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class Article {
  final IconData icon;
  final String title;
  final String summary;
  final String fullContent;
  final String sourceName;
  final String sourceUrl;

  Article({
    required this.icon,
    required this.title,
    required this.summary,
    required this.fullContent,
    required this.sourceName,
    required this.sourceUrl,
  });
}
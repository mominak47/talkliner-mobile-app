// Data model for tabs
import 'package:flutter/widgets.dart';

class TabData {
  final String title;
  final IconData icon;
  final Color color;

  TabData({
    required this.title,
    required this.icon,
    required this.color,
  });
}
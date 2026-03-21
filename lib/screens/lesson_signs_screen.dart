import 'package:flutter/material.dart';

class LessonSignsScreen extends StatefulWidget {
  const LessonSignsScreen({super.key});

  @override
  State<LessonSignsScreen> createState() => _LessonSignsScreenState();
}

class _LessonSignsScreenState extends State<LessonSignsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Lesson Signs")));
  }
}

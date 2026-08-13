import 'package:flutter/material.dart';

class ExamModeView extends StatelessWidget {
  const ExamModeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Exam Mode - Coming Soon'),
      ),
    );
  }
}

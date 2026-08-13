import 'package:flutter/material.dart';

class ReviewQueueView extends StatelessWidget {
  const ReviewQueueView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Queue'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Review Queue - Coming Soon'),
      ),
    );
  }
}

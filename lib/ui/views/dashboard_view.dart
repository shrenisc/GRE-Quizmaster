import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../widgets/xp_badge.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GRE Quizmaster',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  const XpBadge(xp: 1250, streak: 5), // Mock data
                ],
              ),
              const SizedBox(height: 40),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ready for today\'s challenge?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    NeonButton(
                      label: 'Start Daily Drill',
                      onPressed: () {
                        Navigator.pushNamed(context, '/group_list');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/review_queue');
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.replay, size: 48, color: Colors.blueAccent),
                            SizedBox(height: 8),
                            Text('Review Queue'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/exam_mode');
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.assignment, size: 48, color: Colors.deepPurpleAccent),
                            SizedBox(height: 8),
                            Text('Exam Mode'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

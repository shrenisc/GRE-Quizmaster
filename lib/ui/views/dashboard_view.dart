import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../widgets/xp_badge.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/models/user_progress.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ProgressRepository _progressRepo = ProgressRepository();
  UserProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    final progress = await _progressRepo.getProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'GRE Quizmaster',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                        ),
                      ),
                      if (_progress != null)
                        XpBadge(xp: _progress!.xp, streak: _progress!.streakDays)
                      else
                        const SizedBox(width: 80, height: 40, child: CircularProgressIndicator()),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ready for today\'s challenge?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        NeonButton(
                          label: 'Start Daily Drill',
                          onPressed: () {
                            Navigator.pushNamed(context, '/group_list');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/review_queue');
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.replay, size: 48, color: AppTheme.accentColor),
                                  const SizedBox(height: 12),
                                  Text('Review Queue', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
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
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.assignment, size: 48, color: AppTheme.accentColor),
                                  const SizedBox(height: 12),
                                  Text('Exam Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.accentColor,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Account Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.email,
                      label: 'Email',
                      value: user?.email ?? 'Not available',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.badge,
                      label: 'User ID',
                      value: user?.uid ?? 'Not available',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              NeonButton(
                label: 'Sign Out',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // The StreamBuilder in main.dart will automatically
                  // route the user back to the LoginScreen.
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

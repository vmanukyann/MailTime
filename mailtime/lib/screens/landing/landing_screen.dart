import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5FF), Color(0xFFE8F0FF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.schedule_send,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Write to Your Future Self.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create private time capsules filled with text, photos, '
                      'videos, and audio. We deliver them exactly when you '
                      'need them most.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 16,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RoutePaths.signup,
                          ),
                          child: const Text('Get Started'),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            RoutePaths.login,
                          ),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        _FeatureCard(
                          title: 'Free Forever',
                          description:
                              'Unlimited capsules with secure, private storage.',
                        ),
                        _FeatureCard(
                          title: 'Multimedia Support',
                          description:
                              'Capture photos, videos, and audio alongside text.',
                        ),
                        _FeatureCard(
                          title: 'Secure & Private',
                          description:
                              'Your memories stay protected until delivery.',
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.silver),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Start your first capsule today. Future you '
                              'will thank you.',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              RoutePaths.signup,
                            ),
                            child: const Text('Create Capsule'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.silver),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

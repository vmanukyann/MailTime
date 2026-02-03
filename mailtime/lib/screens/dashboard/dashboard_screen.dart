import 'package:flutter/material.dart';

import '../../models/capsule_model.dart';
import '../../services/auth_service.dart';
import '../../services/capsule_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/capsule_card.dart';
import '../../widgets/navbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<CapsuleModel>> _capsulesFuture;

  @override
  void initState() {
    super.initState();
    _capsulesFuture = CapsuleService.instance.fetchCapsules();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.instance.currentUserEmail ?? 'there';

    return Scaffold(
      appBar: const AppNavbar(currentRoute: RoutePaths.dashboard),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<List<CapsuleModel>>(
          future: _capsulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final capsules = snapshot.data ?? [];
            if (capsules.isEmpty) {
              return _EmptyState(onCreate: _goToCreate);
            }

            final upcoming =
                capsules.where((capsule) => !capsule.isDelivered).toList();
            final delivered =
                capsules.where((capsule) => capsule.isDelivered).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back, $userEmail',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your future messages are waiting to be delivered.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _goToCreate,
                        child: const Text('Create New Capsule'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Upcoming Capsules',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _CapsuleGrid(
                    capsules: upcoming,
                    emptyMessage: 'No upcoming capsules yet.',
                  ),
                  const SizedBox(height: 28),
                  Text('Delivered Capsules',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _CapsuleGrid(
                    capsules: delivered,
                    emptyMessage: 'No delivered capsules yet.',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _goToCreate() {
    Navigator.pushNamed(context, RoutePaths.createCapsule);
  }
}

class _CapsuleGrid extends StatelessWidget {
  const _CapsuleGrid({
    required this.capsules,
    required this.emptyMessage,
  });

  final List<CapsuleModel> capsules;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (capsules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.silver),
        ),
        child: Text(emptyMessage),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: capsules
          .map(
            (capsule) => SizedBox(
              width: 320,
              child: CapsuleCard(
                capsule: capsule,
                onView: () => Navigator.pushNamed(
                  context,
                  '${RoutePaths.capsuleBase}/${capsule.id}',
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.silver),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create your first time capsule!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key, this.currentRoute});

  final String? currentRoute;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isAuthed = AuthService.instance.isSignedIn;
    if (!isAuthed) {
      return const SizedBox.shrink();
    }

    return AppBar(
      title: InkWell(
        onTap: () => Navigator.pushNamed(context, RoutePaths.dashboard),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.schedule_send, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      actions: [
        _NavButton(
          label: 'Dashboard',
          isActive: currentRoute == RoutePaths.dashboard,
          onTap: () => Navigator.pushNamed(context, RoutePaths.dashboard),
        ),
        _NavButton(
          label: 'Create Capsule',
          isActive: currentRoute == RoutePaths.createCapsule,
          onTap: () => Navigator.pushNamed(context, RoutePaths.createCapsule),
        ),
        _NavButton(
          label: 'Profile',
          isActive: currentRoute == RoutePaths.profile,
          onTap: () => Navigator.pushNamed(context, RoutePaths.profile),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: OutlinedButton(
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RoutePaths.root,
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: isActive ? AppColors.blueDark : AppColors.slateSoft,
        textStyle: TextStyle(
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      child: Text(label),
    );
  }
}

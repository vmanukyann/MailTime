import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/navbar.dart';

class CapsuleConfirmationArgs {
  const CapsuleConfirmationArgs({
    required this.title,
    required this.deliveryDate,
  });

  final String title;
  final DateTime deliveryDate;
}

class CapsuleConfirmationScreen extends StatefulWidget {
  const CapsuleConfirmationScreen({super.key, required this.args});

  final CapsuleConfirmationArgs args;

  @override
  State<CapsuleConfirmationScreen> createState() =>
      _CapsuleConfirmationScreenState();
}

class _CapsuleConfirmationScreenState extends State<CapsuleConfirmationScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutePaths.dashboard,
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat('MMM d, yyyy • h:mm a').format(widget.args.deliveryDate);

    return Scaffold(
      appBar: const AppNavbar(currentRoute: RoutePaths.dashboard),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Capsule Created Successfully!',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.args.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      RoutePaths.dashboard,
                      (route) => false,
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Redirecting in a moment...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/auth_service.dart';
import '../../services/capsule_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/validators.dart';
import '../../widgets/navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  late Future<_CapsuleStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _emailController.text = AuthService.instance.currentUserEmail ?? '';
    _statsFuture = _loadStats();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<_CapsuleStats> _loadStats() async {
    final capsules = await CapsuleService.instance.fetchCapsules();
    final delivered = capsules.where((c) => c.isDelivered).length;
    return _CapsuleStats(total: capsules.length, delivered: delivered);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final newEmail = _emailController.text.trim();
      if (newEmail.isNotEmpty &&
          newEmail != AuthService.instance.currentUserEmail) {
        await AuthService.instance.updateEmail(newEmail);
      }

      if (_newPasswordController.text.isNotEmpty) {
        final validation = Validators.validatePassword(
          _newPasswordController.text,
        );
        if (validation != null) {
          throw StateError(validation);
        }
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw StateError('Passwords do not match.');
        }
        await AuthService.instance.updatePassword(
          _newPasswordController.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Deleting your account will permanently delete all your capsules. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AuthService.instance.deleteAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutePaths.root,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account deletion requires a secure Edge Function setup.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final createdAtRaw = user?.createdAt?.toString();
    final createdAt = createdAtRaw == null
        ? null
        : DateTime.tryParse(createdAtRaw);
    final joinDate = createdAt == null
        ? 'N/A'
        : DateFormat('MMM d, yyyy').format(createdAt);

    return Scaffold(
      appBar: const AppNavbar(currentRoute: RoutePaths.profile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.silver),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Info',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Text('Email: ${user?.email ?? 'N/A'}'),
                      const SizedBox(height: 6),
                      Text('Join Date: $joinDate'),
                      const SizedBox(height: 12),
                      FutureBuilder<_CapsuleStats>(
                        future: _statsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final stats = snapshot.data!;
                          return Row(
                            children: [
                              _StatChip(
                                label: 'Total Capsules',
                                value: stats.total.toString(),
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                label: 'Delivered',
                                value: stats.delivered.toString(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Edit Profile',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                      labelText: 'Confirm New Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Account Actions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.silver,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _CapsuleStats {
  const _CapsuleStats({required this.total, required this.delivered});

  final int total;
  final int delivered;
}

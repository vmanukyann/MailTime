import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/capsule_model.dart';
import '../utils/theme.dart';
import 'countdown_timer.dart';

class CapsuleCard extends StatelessWidget {
  const CapsuleCard({
    super.key,
    required this.capsule,
    required this.onView,
  });

  final CapsuleModel capsule;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, yyyy • h:mm a').format(
      capsule.deliveryDate,
    );
    final hasMedia = capsule.photoUrl != null ||
        capsule.videoUrl != null ||
        capsule.audioUrl != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    capsule.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: capsule.isDelivered
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    capsule.isDelivered ? 'DELIVERED' : 'UPCOMING',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: capsule.isDelivered
                              ? AppColors.success
                              : AppColors.blueDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dateText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            if (!capsule.isDelivered)
              CountdownTimer(targetDate: capsule.deliveryDate),
            if (capsule.isDelivered) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: onView,
                  child: const Text('View Capsule'),
                ),
              ),
            ],
            if (hasMedia) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (capsule.photoUrl != null)
                    const Icon(Icons.photo, size: 18),
                  if (capsule.videoUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.videocam, size: 18),
                    ),
                  if (capsule.audioUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.mic, size: 18),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    'Includes media',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

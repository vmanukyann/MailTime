import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/media_model.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class MediaRecorder extends StatelessWidget {
  const MediaRecorder({
    super.key,
    required this.photo,
    required this.video,
    required this.audio,
    required this.onAdded,
    required this.onRemoved,
  });

  final MediaAttachment? photo;
  final MediaAttachment? video;
  final MediaAttachment? audio;
  final ValueChanged<MediaAttachment> onAdded;
  final ValueChanged<MediaType> onRemoved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Recording',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MediaButton(
              label: 'Photo Capture',
              icon: Icons.photo_camera,
              isActive: photo == null,
              onTap: () => _pickMedia(context, MediaType.photo),
            ),
            _MediaButton(
              label: 'Video Recording',
              icon: Icons.videocam,
              isActive: video == null,
              onTap: () => _pickMedia(context, MediaType.video),
            ),
            _MediaButton(
              label: 'Audio Recording',
              icon: Icons.mic,
              isActive: audio == null,
              onTap: () => _pickMedia(context, MediaType.audio),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MediaPreview(
          label: 'Photo',
          attachment: photo,
          onRemove: () => onRemoved(MediaType.photo),
        ),
        _MediaPreview(
          label: 'Video',
          attachment: video,
          onRemove: () => onRemoved(MediaType.video),
        ),
        _MediaPreview(
          label: 'Audio',
          attachment: audio,
          onRemove: () => onRemoved(MediaType.audio),
        ),
        const SizedBox(height: 8),
        Text(
          'Tip: Your browser will request camera/microphone access when recording.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _pickMedia(BuildContext context, MediaType type) async {
    final limits = _limitsForType(type);
    final extensions = _extensionsForType(type);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      _showSnack(context, 'Unable to read file data.');
      return;
    }

    if (bytes.length > limits.maxBytes) {
      _showSnack(
        context,
        '${type.label} exceeds the size limit of ${limits.maxLabel}.',
      );
      return;
    }

    final attachment = MediaAttachment(
      type: type,
      bytes: bytes,
      fileName: file.name,
      mimeType: _inferMimeType(type, file.extension),
      sizeBytes: bytes.length,
    );
    onAdded(attachment);
  }

  _MediaLimits _limitsForType(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return const _MediaLimits(AppConstants.photoMaxBytes, '5MB');
      case MediaType.video:
        return const _MediaLimits(AppConstants.videoMaxBytes, '50MB');
      case MediaType.audio:
        return const _MediaLimits(AppConstants.audioMaxBytes, '10MB');
    }
  }

  List<String> _extensionsForType(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return ['jpg', 'jpeg', 'png', 'webp'];
      case MediaType.video:
        return ['mp4', 'webm'];
      case MediaType.audio:
        return ['mp3', 'wav', 'webm'];
    }
  }

  String _inferMimeType(MediaType type, String? extension) {
    final ext = (extension ?? '').toLowerCase();
    switch (type) {
      case MediaType.photo:
        if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
        if (ext == 'png') return 'image/png';
        if (ext == 'webp') return 'image/webp';
        return 'image/*';
      case MediaType.video:
        if (ext == 'mp4') return 'video/mp4';
        if (ext == 'webm') return 'video/webm';
        return 'video/*';
      case MediaType.audio:
        if (ext == 'mp3') return 'audio/mpeg';
        if (ext == 'wav') return 'audio/wav';
        if (ext == 'webm') return 'audio/webm';
        return 'audio/*';
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _MediaButton extends StatelessWidget {
  const _MediaButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isActive ? onTap : null,
      icon: Icon(icon, color: AppColors.blueDark),
      label: Text(label),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({
    required this.label,
    required this.attachment,
    required this.onRemove,
  });

  final String label;
  final MediaAttachment? attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachment == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.silver),
        ),
        child: Row(
          children: [
            Icon(
              _iconForLabel(),
              color: AppColors.blueDark,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$label attached: ${attachment!.fileName}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForLabel() {
    switch (label) {
      case 'Photo':
        return Icons.photo;
      case 'Video':
        return Icons.videocam;
      case 'Audio':
        return Icons.mic;
      default:
        return Icons.attachment;
    }
  }
}

class _MediaLimits {
  const _MediaLimits(this.maxBytes, this.maxLabel);

  final int maxBytes;
  final String maxLabel;
}

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/capsule_model.dart';
import '../../models/media_model.dart';
import '../../services/capsule_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/navbar.dart';
import '../../widgets/rich_text_editor.dart';

class ViewCapsuleScreen extends StatefulWidget {
  const ViewCapsuleScreen({super.key, required this.capsuleId});

  final String capsuleId;

  @override
  State<ViewCapsuleScreen> createState() => _ViewCapsuleScreenState();
}

class _ViewCapsuleScreenState extends State<ViewCapsuleScreen> {
  late Future<CapsuleModel?> _capsuleFuture;

  @override
  void initState() {
    super.initState();
    _capsuleFuture = CapsuleService.instance.fetchCapsuleById(widget.capsuleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(currentRoute: RoutePaths.dashboard),
      body: FutureBuilder<CapsuleModel?>(
        future: _capsuleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final capsule = snapshot.data;
          if (capsule == null) {
            return const Center(child: Text('Capsule not found.'));
          }

          if (!capsule.isDelivered) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This capsule hasn\'t been delivered yet!'),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutePaths.dashboard,
                (route) => false,
              );
            });
            return const SizedBox.shrink();
          }

          return _CapsuleBody(capsule: capsule);
        },
      ),
    );
  }
}

class _CapsuleBody extends StatefulWidget {
  const _CapsuleBody({required this.capsule});

  final CapsuleModel capsule;

  @override
  State<_CapsuleBody> createState() => _CapsuleBodyState();
}

class _CapsuleBodyState extends State<_CapsuleBody> {
  late Future<_ResolvedMedia> _mediaFuture;

  @override
  void initState() {
    super.initState();
    _mediaFuture = _resolveMedia();
  }

  Future<_ResolvedMedia> _resolveMedia() async {
    final photo = await StorageService.instance.resolveMediaUrl(
      type: MediaType.photo,
      pathOrUrl: widget.capsule.photoUrl,
    );
    final video = await StorageService.instance.resolveMediaUrl(
      type: MediaType.video,
      pathOrUrl: widget.capsule.videoUrl,
    );
    final audio = await StorageService.instance.resolveMediaUrl(
      type: MediaType.audio,
      pathOrUrl: widget.capsule.audioUrl,
    );
    return _ResolvedMedia(photoUrl: photo, videoUrl: video, audioUrl: audio);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, yyyy • h:mm a')
        .format(widget.capsule.deliveredAt ?? widget.capsule.deliveryDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.capsule.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Delivered on $dateText',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              RichTextViewer(documentJson: widget.capsule.contentText),
              const SizedBox(height: 20),
              FutureBuilder<_ResolvedMedia>(
                future: _mediaFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final media = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (media.photoUrl != null) ...[
                        Text('Photo',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(media.photoUrl!),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (media.videoUrl != null) ...[
                        Text('Video',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _WebMediaPlayer(
                          url: media.videoUrl!,
                          type: MediaType.video,
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (media.audioUrl != null) ...[
                        Text('Audio',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _WebMediaPlayer(
                          url: media.audioUrl!,
                          type: MediaType.audio,
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResolvedMedia {
  const _ResolvedMedia({
    required this.photoUrl,
    required this.videoUrl,
    required this.audioUrl,
  });

  final String? photoUrl;
  final String? videoUrl;
  final String? audioUrl;
}

class _WebMediaPlayer extends StatelessWidget {
  const _WebMediaPlayer({required this.url, required this.type});

  final String url;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Text('Media available at $url');
    }

    final viewType = 'media-${type.name}-${url.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      if (type == MediaType.video) {
        final element = html.VideoElement()
          ..src = url
          ..controls = true
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.borderRadius = '16px';
        return element;
      }
      final element = html.AudioElement()
        ..src = url
        ..controls = true
        ..style.width = '100%';
      return element;
    });

    return Container(
      height: type == MediaType.video ? 320 : 64,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silver),
      ),
      child: HtmlElementView(viewType: viewType),
    );
  }
}

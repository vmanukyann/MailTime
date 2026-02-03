import '../models/capsule_model.dart';
import '../models/media_model.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

class CapsuleService {
  CapsuleService._();

  static final CapsuleService instance = CapsuleService._();

  Future<List<CapsuleModel>> fetchCapsules() async {
    final response = await SupabaseService.instance.client
        .from('capsules')
        .select()
        .order('delivery_date', ascending: true);

    return (response as List<dynamic>)
        .map((item) => CapsuleModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<CapsuleModel?> fetchCapsuleById(String id) async {
    final response = await SupabaseService.instance.client
        .from('capsules')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }
    return CapsuleModel.fromMap(response);
  }

  Future<CapsuleModel> createCapsule({
    required String title,
    required String contentText,
    required DateTime deliveryDate,
    MediaAttachment? photo,
    MediaAttachment? video,
    MediaAttachment? audio,
  }) async {
    final userId = AuthService.instance.currentUserId;

    final inserted = await SupabaseService.instance.client
        .from('capsules')
        .insert({
          'user_id': userId,
          'title': title,
          'content_text': contentText,
          'delivery_date': deliveryDate.toIso8601String(),
          'is_delivered': false,
        })
        .select()
        .single();

    var capsule = CapsuleModel.fromMap(inserted);

    final updates = <String, dynamic>{};

    if (photo != null) {
      updates['photo_url'] = await StorageService.instance.uploadMedia(
        type: MediaType.photo,
        bytes: photo.bytes,
        userId: userId,
        capsuleId: capsule.id,
        extension: _extensionFromFileName(photo.fileName),
        contentType: photo.mimeType,
      );
    }

    if (video != null) {
      updates['video_url'] = await StorageService.instance.uploadMedia(
        type: MediaType.video,
        bytes: video.bytes,
        userId: userId,
        capsuleId: capsule.id,
        extension: _extensionFromFileName(video.fileName),
        contentType: video.mimeType,
      );
    }

    if (audio != null) {
      updates['audio_url'] = await StorageService.instance.uploadMedia(
        type: MediaType.audio,
        bytes: audio.bytes,
        userId: userId,
        capsuleId: capsule.id,
        extension: _extensionFromFileName(audio.fileName),
        contentType: audio.mimeType,
      );
    }

    if (updates.isNotEmpty) {
      final updated = await SupabaseService.instance.client
          .from('capsules')
          .update(updates)
          .eq('id', capsule.id)
          .select()
          .single();
      capsule = CapsuleModel.fromMap(updated);
    }

    return capsule;
  }

  String _extensionFromFileName(String name) {
    final parts = name.split('.');
    if (parts.length < 2) {
      return 'bin';
    }
    return parts.last.toLowerCase();
  }
}

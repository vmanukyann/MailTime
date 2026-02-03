import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/media_model.dart';
import '../utils/constants.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  String _bucketForType(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return 'capsule-photos';
      case MediaType.video:
        return 'capsule-videos';
      case MediaType.audio:
        return 'capsule-audio';
    }
  }

  Future<String> uploadMedia({
    required MediaType type,
    required Uint8List bytes,
    required String userId,
    required String capsuleId,
    required String extension,
    required String contentType,
  }) async {
    final bucket = _bucketForType(type);
    final fileName = '${capsuleId}_${type.name}.$extension';
    final path = '$userId/$fileName';

    await _client.storage
        .from(bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));

    return path;
  }

  Future<String?> resolveMediaUrl({
    required MediaType type,
    required String? pathOrUrl,
  }) async {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return null;
    }
    if (pathOrUrl.startsWith('http')) {
      return pathOrUrl;
    }
    final bucket = _bucketForType(type);
    final signed = await _client.storage
        .from(bucket)
        .createSignedUrl(pathOrUrl, AppConstants.signedUrlExpirySeconds);
    return signed;
  }
}

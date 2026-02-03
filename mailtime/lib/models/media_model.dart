import 'dart:typed_data';

enum MediaType { photo, video, audio }

class MediaAttachment {
  const MediaAttachment({
    required this.type,
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final MediaType type;
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
}

extension MediaTypeX on MediaType {
  String get label {
    switch (this) {
      case MediaType.photo:
        return 'Photo';
      case MediaType.video:
        return 'Video';
      case MediaType.audio:
        return 'Audio';
    }
  }
}

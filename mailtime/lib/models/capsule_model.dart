class CapsuleModel {
  CapsuleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.contentText,
    required this.deliveryDate,
    required this.isDelivered,
    this.deliveredAt,
    this.photoUrl,
    this.videoUrl,
    this.audioUrl,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String contentText;
  final DateTime deliveryDate;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final String? photoUrl;
  final String? videoUrl;
  final String? audioUrl;
  final DateTime createdAt;

  factory CapsuleModel.fromMap(Map<String, dynamic> map) {
    return CapsuleModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      contentText: map['content_text'] as String? ?? '',
      deliveryDate: DateTime.parse(map['delivery_date'] as String),
      isDelivered: map['is_delivered'] as bool? ?? false,
      deliveredAt: map['delivered_at'] == null
          ? null
          : DateTime.parse(map['delivered_at'] as String),
      photoUrl: map['photo_url'] as String?,
      videoUrl: map['video_url'] as String?,
      audioUrl: map['audio_url'] as String?,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content_text': contentText,
      'delivery_date': deliveryDate.toIso8601String(),
      'is_delivered': isDelivered,
      'delivered_at': deliveredAt?.toIso8601String(),
      'photo_url': photoUrl,
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

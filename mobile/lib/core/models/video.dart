class Video {
  final String videoId;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String channelId;
  final String? channelName;
  final DateTime publishedAt;
  final int? durationSeconds;

  Video({
    required this.videoId,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.channelId,
    this.channelName,
    required this.publishedAt,
    this.durationSeconds,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['videoId'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      channelId: json['channelId'],
      channelName: json['channelName'],
      publishedAt: DateTime.parse(json['publishedAt']),
      durationSeconds: json['durationSeconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'channelId': channelId,
      'channelName': channelName,
      'publishedAt': publishedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }
}


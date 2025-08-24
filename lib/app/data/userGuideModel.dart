class UserGuideCategoryModel {
  final int id;
  final String title;
  final List<GuideItemModel> items;

  UserGuideCategoryModel({
    required this.id,

    required this.title,
    required this.items,
  });

  factory UserGuideCategoryModel.fromJson(Map<String, dynamic> json) {
    return UserGuideCategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => GuideItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class GuideItemModel {
  final int id;
  final int guide_id;
  final String title;
  final String description;
  final String content;
  final List<String> images;
  final String videoUrl;
  final String lastUpdated;

  GuideItemModel({
    required this.id,
    required this.guide_id,
    required this.title,
    required this.description,
    required this.content,
    required this.images,
    required this.videoUrl,
    required this.lastUpdated,
  });

  factory GuideItemModel.fromJson(Map<String, dynamic> json) {
    return GuideItemModel(
      id: json['id'] ?? 0,
      guide_id: json['guide_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videoUrl: json['video_url'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'images': images,
      'video_url': videoUrl,
      'last_updated': lastUpdated,
      'guide_id': guide_id,
    };
  }
}

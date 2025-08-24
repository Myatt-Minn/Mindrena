class AdData {
  final String id;
  final String imageUrl;
  final String actionType; // 'product', 'category', 'url', 'none'
  final String actionValue;

  AdData({
    required this.id,
    required this.imageUrl,

    this.actionType = 'none',
    this.actionValue = '',
  });

  factory AdData.fromJson(Map<String, dynamic> json) {
    return AdData(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      actionType: json['action_type'] ?? 'none',
      actionValue: json['action_value'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'action_type': actionType,
      'action_value': actionValue,
    };
  }
}

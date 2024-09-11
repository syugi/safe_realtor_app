class Property {
  final String type;
  final String price;
  final String description;
  final List<String> imageUrls;

  Property(
      {required this.type,
      required this.price,
      required this.description,
      required this.imageUrls});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      type: json['type'],
      price: json['price'],
      description: json['description'],
      imageUrls:
          json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
    );
  }

  String thumbnailUrl() {
    return imageUrls.isNotEmpty
        ? imageUrls.first
        : 'assets/images/default_thumbnail.png'; // 기본 썸네일 경로
  }
}

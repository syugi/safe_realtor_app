class Property {
  final int id;
  final String type;
  final String price;
  final String description;
  final List<String> imageUrls;
  bool isFavorite;

  Property(
      {required this.id,
      required this.type,
      required this.price,
      required this.description,
      required this.imageUrls,
      required this.isFavorite});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      type: json['type'],
      price: json['price'],
      description: json['description'],
      imageUrls:
          json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      isFavorite: json['isFavorite'],
    );
  }

  String thumbnailUrl() {
    return imageUrls.isNotEmpty
        ? imageUrls.first
        : 'assets/images/default_thumbnail.png'; // 기본 썸네일 경로
  }
}

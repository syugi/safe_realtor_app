class Property {
  final String type;
  final String price;
  final String description;

  Property(
      {required this.type, required this.price, required this.description});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      type: json['type'],
      price: json['price'],
      description: json['description'],
    );
  }
}

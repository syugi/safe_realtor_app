class Property {
  final int id;
  final String propertyNumber;
  final String price;
  final String description;
  final String type;
  final String maintenanceFee;
  final bool parkingAvailable;
  final String roomType;
  final String floor;
  final double area;
  final int rooms;
  final int bathrooms;
  final String direction;
  final String heatingType;
  final bool elevatorAvailable;
  final int totalParkingSlots;
  final String entranceType;
  final String availableMoveInDate;
  final String buildingUse;
  final DateTime approvalDate;
  final DateTime firstRegistrationDate;
  final String options;
  final String securityFacilities;
  final String address;
  final List<String> imageUrls;
  final DateTime registeredAt;
  bool isFavorite;

  Property({
    required this.id,
    required this.propertyNumber,
    required this.price,
    required this.description,
    required this.type,
    required this.maintenanceFee,
    required this.parkingAvailable,
    required this.roomType,
    required this.floor,
    required this.area,
    required this.rooms,
    required this.bathrooms,
    required this.direction,
    required this.heatingType,
    required this.elevatorAvailable,
    required this.totalParkingSlots,
    required this.entranceType,
    required this.availableMoveInDate,
    required this.buildingUse,
    required this.approvalDate,
    required this.firstRegistrationDate,
    required this.options,
    required this.securityFacilities,
    required this.address,
    required this.imageUrls,
    required this.registeredAt,
    required this.isFavorite,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      propertyNumber: json['propertyNumber'],
      price: json['price'],
      description: json['description'],
      type: json['type'],
      maintenanceFee: json['maintenanceFee'] ?? '',
      parkingAvailable: json['parkingAvailable'] ?? false,
      roomType: json['roomType'] ?? '',
      floor: json['floor'] ?? '',
      area: json['area']?.toDouble() ?? 0.0,
      rooms: json['rooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      direction: json['direction'] ?? '',
      heatingType: json['heatingType'] ?? '',
      elevatorAvailable: json['elevatorAvailable'] ?? false,
      totalParkingSlots: json['totalParkingSlots'] ?? 0,
      entranceType: json['entranceType'] ?? '',
      availableMoveInDate: json['availableMoveInDate'] ?? '',
      buildingUse: json['buildingUse'] ?? '',
      approvalDate: DateTime.parse(json['approvalDate']),
      firstRegistrationDate: DateTime.parse(json['firstRegistrationDate']),
      options: json['options'] ?? '',
      securityFacilities: json['securityFacilities'] ?? '',
      address: json['address'] ?? '',
      imageUrls:
          json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      registeredAt: DateTime.parse(json['registeredAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  String thumbnailUrl() {
    return imageUrls.isNotEmpty
        ? imageUrls.first
        : 'assets/images/default_thumbnail.png'; // 기본 썸네일 경로
  }
}

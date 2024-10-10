import 'package:safe_realtor_app/utils/date_utils.dart';

class Property {
  final int id;
  final String propertyNumber;
  final String price;
  final String title;
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
  final String approvalDate;
  final String firstRegistrationDate;
  final String options;
  final String securityFacilities;
  final String address;
  final List<String> imageUrls;
  final DateTime createdAt;
  bool isFavorite;
  final String thumbnailUrl;

  Property(
      {required this.id,
      required this.propertyNumber,
      required this.price,
      required this.title,
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
      required this.createdAt,
      required this.isFavorite,
      required this.thumbnailUrl});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
        id: json['id'],
        propertyNumber: json['propertyNumber'],
        price: json['price'],
        title: json['title'],
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
        approvalDate: parseDate(json['approvalDate']),
        firstRegistrationDate: parseDate(json['firstRegistrationDate']),
        options: json['options'] ?? '',
        securityFacilities: json['securityFacilities'] ?? '',
        address: json['address'] ?? '',
        imageUrls: json['imageUrls'] != null
            ? List<String>.from(json['imageUrls'])
            : [],
        createdAt: DateTime.parse(json['createdAt']),
        isFavorite: json['isFavorite'] ?? false,
        thumbnailUrl: json['thumbnailUrl'] ??
            'https://saferealtor-app-data.s3.ap-northeast-2.amazonaws.com/default_thumbnail.png');
  }
}

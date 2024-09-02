import 'package:flutter/material.dart';
import '../../services/property_service.dart';
import 'property_detail_screen.dart';
import 'package:safe_realtor_app/models/Property.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyService _propertyService = PropertyService();

  late Future<List<Property>> _propertyList;

  @override
  void initState() {
    super.initState();
    _propertyList = _propertyService.fetchProperties(); // 매물 목록 조회
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매물 목록'),
      ),
      body: FutureBuilder<List<Property>>(
        future: _propertyList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('조회된 매물이 없습니다.'));
          }

          final properties = snapshot.data!;

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return ListTile(
                title: Text('${property.type} - ${property.price}'),
                subtitle: Text(property.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PropertyDetailScreen(property: property),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

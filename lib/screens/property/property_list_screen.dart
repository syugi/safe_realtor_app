import 'package:flutter/material.dart';
import '../../services/property_service.dart';
import 'property_detail_screen.dart';
import 'package:safe_realtor_app/models/Property.dart';
import 'dart:async';
import 'package:safe_realtor_app/config.dart';

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
    _loadProperties(); // 매물 목록 조회
  }

  // 매물 목록을 다시 로드하는 함수
  Future<void> _loadProperties() async {
    setState(() {
      _propertyList = _propertyService.fetchProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
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

        return RefreshIndicator(
          onRefresh: _loadProperties, // 새로고침 시 호출
          child: ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return ListTile(
                leading: property.imageUrls.isNotEmpty
                    ? Image.network(
                        '${Config.apiBaseUrl}${property.imageUrls.first}', // 첫 번째 이미지를 썸네일로 표시
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/default_thumbnail.png', // 로컬 기본 썸네일 이미지
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
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
          ),
        );
      },
    );
  }
}

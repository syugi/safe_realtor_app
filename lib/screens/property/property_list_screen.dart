import 'dart:io';

import 'package:flutter/material.dart';
import '../../services/property_service.dart';
import 'property_detail_screen.dart';
import 'package:safe_realtor_app/models/Property.dart';
import 'dart:async';
import 'package:safe_realtor_app/config.dart';
import 'package:safe_realtor_app/utils/message_utils.dart';
import 'package:logger/logger.dart';

class PropertyListScreen extends StatefulWidget {
  final String userId;
  const PropertyListScreen({super.key, required this.userId});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final PropertyService _propertyService = PropertyService();
  final Logger _logger = Logger();

  late Future<List<Property>> _propertyList;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProperties(); // 매물 목록 조회
  }

  // 매물 목록을 다시 로드하는 함수
  Future<void> _loadProperties() async {
    setState(() {
      _errorMessage = null; // 오류 메시지 초기화
      _propertyList = _fetchPropertiesWithHandling();
    });
  }

  // 매물 목록을 가져오는 함수 (에러 핸들링 추가)
  Future<List<Property>> _fetchPropertiesWithHandling() async {
    try {
      return await _propertyService.fetchProperties(widget.userId);
    } on SocketException catch (e) {
      setState(() {
        _errorMessage = '인터넷 연결이 없습니다. 연결을 확인해주세요.';
      });
      _logger.e(_errorMessage, error: e);
      return [];
    } catch (e) {
      setState(() {
        _errorMessage = '매물 목록을 불러오는 중 오류가 발생했습니다.';
      });
      _logger.e(_errorMessage, error: e);
      return [];
    }
  }

  void _toggleFavorite(Property property) {
    try {
      setState(() {
        if (property.isFavorite ?? false) {
          property.isFavorite = false; // 찜 취소
          _propertyService.removeFavorite(widget.userId, property.id);
        } else {
          property.isFavorite = true; // 찜 추가
          _propertyService.addFavorite(widget.userId, property.id);
        }
      });
    } catch (e) {
      showErrorMessage(context, '찜 상태를 변경하는 중 오류가 발생했습니다.',
          error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
      future: _propertyList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (_errorMessage != null) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _loadProperties, child: const Text('새로고침')),
            ],
          ));
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
              final isFavorite = property.isFavorite ?? false; // 서버에서 받은 찜 여부

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
                trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(property)),
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

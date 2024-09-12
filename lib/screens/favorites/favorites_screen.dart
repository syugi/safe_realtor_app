import 'package:flutter/material.dart';
import '../../services/property_service.dart';
import '../../models/Property.dart';
import '../property/property_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final String userId;
  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PropertyService _propertyService = PropertyService();
  List<Property> _favoriteProperties = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteProperties();
  }

  // 찜한 매물 목록 불러오기
  Future<void> _loadFavoriteProperties() async {
    try {
      // PropertyService를 통해 찜한 매물 목록을 가져옵니다.
      List<Property> favoriteProperties =
          await _propertyService.getFavoriteProperties(widget.userId);

      setState(() {
        _favoriteProperties = favoriteProperties;
      });
    } catch (e) {
      // 에러가 발생한 경우 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('찜 목록을 불러오는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  void _removeFavorite(Property property) async {
    try {
      await _propertyService.removeFavorite(widget.userId, property.id);

      setState(() {
        _favoriteProperties.remove(property); // 목록에서 매물 삭제
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('찜 목록에서 제거되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('찜 제거 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('찜한 매물 목록'),
        ),
        body: _favoriteProperties.isEmpty
            ? const Center(child: Text('찜한 매물이 없습니다.'))
            : ListView.builder(
                itemCount: _favoriteProperties.length,
                itemBuilder: (context, index) {
                  final property = _favoriteProperties[index];
                  return ListTile(
                    leading: property.imageUrls.isNotEmpty
                        ? Image.network(
                            property.imageUrls[0], // 첫 번째 이미지 썸네일로 사용
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/default_thumbnail.png', // 썸네일이 없을 때 기본 이미지
                            width: 50,
                            height: 50,
                          ),
                    title: Text('${property.type} - ${property.price}'),
                    subtitle: Text(property.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // 찜 취소 로직 추가
                        _removeFavorite(property);
                      },
                    ),
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
                }));
  }
}

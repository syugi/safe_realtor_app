import 'package:flutter/material.dart';
import '../../services/property_service.dart';
import 'property_detail_screen.dart';
import 'package:safe_realtor_app/models/Property.dart';
import 'dart:async';
import 'dart:io';
import 'package:safe_realtor_app/config.dart';
import 'package:safe_realtor_app/utils/message_utils.dart';
import 'package:logger/logger.dart';
import 'package:safe_realtor_app/utils/user_utils.dart';
import 'package:safe_realtor_app/mixins/login_helper.dart';

class PropertyListScreen extends StatefulWidget {
  final String userId;
  const PropertyListScreen({super.key, required this.userId});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen>
    with LoginHelper {
  final PropertyService _propertyService = PropertyService();
  final Logger _logger = Logger();

  final ScrollController _scrollController = ScrollController();

  final List<Property> _properties = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 10; // 한 번에 불러올 매물 수

  @override
  void initState() {
    super.initState();
    _loadProperties(); // 초기 데이터 로드
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollController 해제
    super.dispose();
  }

  // 스크롤이 끝에 도달했을 때 데이터를 더 불러오는 함수
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadProperties(); // 추가 매물 불러오기
      }
    }
  }

  // 매물 목록을 다시 로드하는 함수
  Future<void> _loadProperties() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newProperties = await _propertyService.fetchProperties(
        widget.userId,
        page: _currentPage,
        perPage: _perPage,
      );

      setState(() {
        _properties.addAll(newProperties); // 새로운 매물 추가
        _currentPage++; // 다음 페이지로 넘김
        _hasMore = newProperties.length == _perPage; // 다음 페이지에 더 있을지 확인
        _isLoading = false;
      });
    } on SocketException catch (e) {
      setState(() {
        _errorMessage = '인터넷 연결이 없습니다. 연결을 확인해주세요.';
        _isLoading = false;
      });
      _logger.e(_errorMessage, error: e);
    } catch (e) {
      setState(() {
        _errorMessage = '매물 목록을 불러오는 중 오류가 발생했습니다.';
        _isLoading = false;
      });
      _logger.e(_errorMessage, error: e);
    }
  }

// 로그인 여부 체크 후 찜 기능 실행
  void _handleFavorite(Property property) async {
    bool loggedIn = await isLoggedIn(); // LoginHelper 사용하여 로그인 여부 확인

    if (loggedIn) {
      _toggleFavorite(property);
    } else {
      showLoginBottomSheet(context); // 로그인 모달 띄우기
    }
  }

  void _toggleFavorite(Property property) {
    try {
      setState(() {
        if (property.isFavorite) {
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

  Widget _buildPropertyImage(Property property) {
    return property.imageUrls.isNotEmpty
        ? Image.network(
            '${Config.apiBaseUrl}${property.imageUrls.first}',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
        : Image.asset(
            'assets/images/default_thumbnail.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: _loadProperties,
                    icon: const Icon(Icons.refresh),
                    tooltip: '새로고침',
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // 새로고침 시 데이터 초기화
                setState(() {
                  _properties.clear();
                  _currentPage = 1;
                  _hasMore = true;
                });
                await _loadProperties();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _properties.length + 1, // 로딩 인디케이터를 위해 +1
                itemBuilder: (context, index) {
                  if (index == _properties.length) {
                    // 로딩 인디케이터 표시
                    return _hasMore
                        ? const Center(child: CircularProgressIndicator())
                        : const Center(child: Text(''));
                  }

                  final property = _properties[index];
                  return ListTile(
                    leading: _buildPropertyImage(property),
                    title: Text('${property.type} - ${property.price}'),
                    subtitle: Text(property.description),
                    trailing: IconButton(
                      icon: Icon(
                        property.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: property.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => _handleFavorite(property),
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
                },
              ),
            ),
    );
  }
}

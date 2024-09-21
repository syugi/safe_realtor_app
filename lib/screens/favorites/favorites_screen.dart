import 'dart:io';
import 'package:flutter/material.dart';
import 'package:safe_realtor_app/widgets/property/property_card.dart';
import '../../services/property_service.dart';
import 'package:safe_realtor_app/models/Property.dart';
import 'package:logger/logger.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PropertyService _propertyService = PropertyService();
  final Logger _logger = Logger();

  final ScrollController _scrollController = ScrollController();

  final List<Property> _favoriteProperties = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 10; // 한 번에 불러올 매물 수

  @override
  void initState() {
    super.initState();
    _loadFavoriteProperties();
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
        _loadFavoriteProperties(); // 추가 찜 목록 불러오기
      }
    }
  }

  // 찜 목록을 다시 로드하는 함수
  Future<void> _loadFavoriteProperties() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newProperties = await _propertyService.fetchFavoriteProperties(
        _currentPage,
        _perPage,
      );

      setState(() {
        _favoriteProperties.addAll(newProperties); // 새로운 매물 추가
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('찜 목록'),
      ),
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: _loadFavoriteProperties,
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
                  _favoriteProperties.clear();
                  _currentPage = 1;
                  _hasMore = true;
                });
                await _loadFavoriteProperties();
              },
              child: _favoriteProperties.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                        '찜한 매물이 없습니다.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _favoriteProperties.length + 1, // 로딩 인디케이터를 위해 +1
                      itemBuilder: (context, index) {
                        if (index == _favoriteProperties.length) {
                          // 로딩 인디케이터 표시
                          return _hasMore
                              ? const Center(child: CircularProgressIndicator())
                              : const Center(child: Text(''));
                        }
                        return PropertyCard(
                          property: _favoriteProperties[index],
                        );
                      },
                    ),
            ),
    );
  }
}

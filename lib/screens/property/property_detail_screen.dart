import 'package:flutter/material.dart';
import 'package:safe_realtor_app/models/Property.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:safe_realtor_app/services/property_service.dart';
import 'package:safe_realtor_app/utils/message_utils.dart';
import 'package:safe_realtor_app/mixins/login_helper.dart';
import 'package:safe_realtor_app/screens/inquiry/inquiry_form_screen.dart';
import 'package:safe_realtor_app/styles/app_styles.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with LoginHelper<PropertyDetailScreen> {
  final PropertyService _propertyService = PropertyService();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('매물 ${widget.property.propertyNumber}'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.share),
            //   onPressed: () {}, // 공유 기능 구현
            // ),
            IconButton(
                icon: Icon(
                  widget.property.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.property.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.property.imageUrls.isNotEmpty
                    ? Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: false,
                              aspectRatio: 1.5,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: false,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                            ),
                            items: widget.property.imageUrls
                                .map((item) => Container(
                                      child: Center(
                                          child: Image.network(item,
                                              fit: BoxFit.cover, width: 1000)),
                                    ))
                                .toList(),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              color:
                                  Colors.black45, // 텍스트의 가독성을 높이기 위해 반투명 배경 추가
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 20.0),
                              child: Text(
                                "${_current + 1} / ${widget.property.imageUrls.length}",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Image.asset(
                        'assets/images/default_thumbnail.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.property.type} ${widget.property.price}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(widget.property.title,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: [
                          Chip(
                            label: Text(widget.property.roomType),
                            avatar: const Icon(Icons.house_outlined),
                          ),
                          Chip(
                            label: Text('${widget.property.area}㎡'),
                            avatar: const Icon(Icons.square_foot_outlined),
                          ),
                          Chip(
                            label: Text(widget.property.maintenanceFee),
                            avatar: const Icon(Icons.receipt_sharp),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.property.parkingAvailable)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[300],
                              child: const Text('주차 가능'),
                            ),
                          const SizedBox(
                            width: 10,
                          ),
                          if (widget.property.elevatorAvailable)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey[300],
                              child: const Text('엘리베이터 있음'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      buildDetailSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: AppStyles.wideElevatedButtonStyle,
            onPressed: () {
              _handleLoginRequired(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InquiryFormScreen(
                            propertyNumbers: [widget.property.propertyNumber],
                          )),
                );
              });
            },
            child: const Text('문의하기'),
          ),
        ));
  }

  Widget buildDetailSection() {
    return Column(
      children: [
        buildRowWithDivider(widget.property.type, widget.property.price),
        buildRowWithDivider('관리비', widget.property.maintenanceFee),
        buildRowWithDivider(
            '주차 가능 여부', widget.property.parkingAvailable ? '있음' : '없음'),
        buildRowWithDivider('방 종류', widget.property.roomType),
        buildRowWithDivider('해당 층/건물 층', widget.property.floor),
        buildRowWithDivider('전용/공급 면적', '${widget.property.area}㎡'),
        buildRowWithDivider(
            '방수/욕실수', '${widget.property.rooms}/${widget.property.bathrooms}'),
        buildRowWithDivider('방향', widget.property.direction),
        buildRowWithDivider(
            '엘리베이터', widget.property.elevatorAvailable ? '있음' : '없음'),
        buildRowWithDivider('총 주차 대수', '${widget.property.totalParkingSlots}대'),
        buildRowWithDivider('입주 가능일', widget.property.availableMoveInDate),
        buildRowWithDivider('건축물 용도', widget.property.buildingUse),
        buildRowWithDivider('사용승인일', formatDate(widget.property.approvalDate)),
        buildRowWithDivider(
            '최초등록일', formatDate(widget.property.firstRegistrationDate)),
        buildRowWithDivider('위치', widget.property.address),
      ],
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  Widget buildRowWithDivider(String label, dynamic value) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  TableRow buildRow(String label, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value.toString()),
        ),
      ],
    );
  }

  void _toggleFavorite() async {
    bool loggedIn = await isLoggedIn();
    if (loggedIn) {
      try {
        setState(() {
          widget.property.isFavorite = !widget.property.isFavorite;
          if (widget.property.isFavorite) {
            _propertyService.addFavorite(widget.property.id);
          } else {
            _propertyService.removeFavorite(widget.property.id);
          }
        });
      } catch (e) {
        showErrorMessage(context, '찜 상태를 변경하는 중 오류가 발생했습니다.',
            error: e.toString());
      }
    } else {
      showLoginBottomSheet(context);
    }
  }

  // 로그인 여부를 확인하여 로그인하지 않았다면 로그인 창 모달을 띄우는 함수
  void _handleLoginRequired(VoidCallback onLoggedIn) async {
    bool loggedIn = await isLoggedIn();

    if (loggedIn) {
      onLoggedIn();
    } else {
      showLoginBottomSheet(context);
    }
  }
}

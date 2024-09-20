import 'package:flutter/material.dart';
import 'package:safe_realtor_app/services/property_service.dart';
import 'package:safe_realtor_app/utils/http_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:safe_realtor_app/utils/message_utils.dart';

class PropertyRegistrationScreen extends StatefulWidget {
  const PropertyRegistrationScreen({super.key});

  @override
  State<PropertyRegistrationScreen> createState() =>
      _PropertyRegistrationScreenState();
}

class _PropertyRegistrationScreenState
    extends State<PropertyRegistrationScreen> {
  final PropertyService _propertyService = PropertyService();
  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker

  List<File> _images = []; // 여러 개의 선택한 이미지 파일을 저장할 리스트

  final Map<String, TextEditingController> _controllers = {
    'propertyNumber': TextEditingController(),
    'price': TextEditingController(),
    'description': TextEditingController(),
    'maintenanceFee': TextEditingController(),
    'roomType': TextEditingController(),
    'floor': TextEditingController(),
    'area': TextEditingController(),
    'rooms': TextEditingController(),
    'bathrooms': TextEditingController(),
    'direction': TextEditingController(),
    'heatingType': TextEditingController(),
    'totalParkingSlots': TextEditingController(),
    'entranceType': TextEditingController(),
    'availableMoveInDate': TextEditingController(),
    'buildingUse': TextEditingController(),
    'approvalDate': TextEditingController(),
    'firstRegistrationDate': TextEditingController(),
    'options': TextEditingController(),
    'securityFacilities': TextEditingController(),
  };

  String? selectedType;
  bool parkingAvailable = false;
  bool elevatorAvailable = false;

  // 이미지 선택 함수
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();

    setState(() {
      _images = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    });
  }

  Future<void> _registerProperty() async {
    final property = _buildPropertyData();
    final response = await _propertyService.sendPropertyData(property, _images);

    if (response.statusCode == HttpStatus.created) {
      showSuccessMessage(context, '매물 등록 성공!');
    } else {
      final message = extractMessageFromResponse(response);
      showErrorMessage(context, '매물 등록 실패: $message');
    }
  }

  Map<String, dynamic> _buildPropertyData() {
    return {
      'agentId': 1, //중개사 아이디 임시
      'propertyNumber': _controllers['propertyNumber']?.text,
      'price': double.tryParse(_controllers['price']?.text ?? ''),
      'description': _controllers['description']?.text,
      'type': selectedType,
      'maintenanceFee':
          double.tryParse(_controllers['maintenanceFee']?.text ?? ''),
      'parkingAvailable': parkingAvailable,
      'roomType': _controllers['roomType']?.text,
      'floor': _controllers['floor']?.text,
      'area': double.tryParse(_controllers['area']?.text ?? ''),
      'rooms': int.tryParse(_controllers['rooms']?.text ?? ''),
      'bathrooms': int.tryParse(_controllers['bathrooms']?.text ?? ''),
      'direction': _controllers['direction']?.text,
      'heatingType': _controllers['heatingType']?.text,
      'elevatorAvailable': elevatorAvailable,
      'totalParkingSlots':
          int.tryParse(_controllers['totalParkingSlots']?.text ?? ''),
      'entranceType': _controllers['entranceType']?.text,
      'availableMoveInDate': _controllers['availableMoveInDate']?.text,
      'buildingUse': _controllers['buildingUse']?.text,
      'approvalDate': _controllers['approvalDate']?.text,
      'firstRegistrationDate': _controllers['firstRegistrationDate']?.text,
      'options': _controllers['options']?.text,
      'securityFacilities': _controllers['securityFacilities']?.text,
    };
  }

  Widget _buildTextField(String key, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildSwitchListTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부동산 매물 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('propertyNumber', '매물번호'),
            _buildTextField('price', '가격', keyboardType: TextInputType.number),
            _buildTextField('description', '소개'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImages, // 여러 이미지 선택 버튼
              child: const Text('이미지 선택 (여러 장)'),
            ),
            const SizedBox(height: 16.0),
            // 선택한 이미지 미리보기
            _images.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.file(
                            _images[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
                : const Text('이미지가 선택되지 않았습니다.'),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '종류 선택 (전세/월세/매매)',
              ),
              items: ['전세', '월세', '매매'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildTextField('maintenanceFee', '관리비',
                keyboardType: TextInputType.number),
            _buildSwitchListTile('주차 가능 여부', parkingAvailable, (value) {
              setState(() {
                parkingAvailable = value;
              });
            }),
            _buildTextField('roomType', '방 종류'),
            _buildTextField('floor', '해당층/건물층'),
            _buildTextField('area', '전용면적', keyboardType: TextInputType.number),
            _buildTextField('rooms', '방수', keyboardType: TextInputType.number),
            _buildTextField('bathrooms', '욕실수',
                keyboardType: TextInputType.number),
            _buildTextField('direction', '방향'),
            _buildTextField('heatingType', '난방 종류'),
            _buildSwitchListTile('엘리베이터 여부', elevatorAvailable, (value) {
              setState(() {
                elevatorAvailable = value;
              });
            }),
            _buildTextField('totalParkingSlots', '총 주차대수',
                keyboardType: TextInputType.number),
            _buildTextField('entranceType', '현관 유형'),
            _buildTextField('availableMoveInDate', '입주 가능일',
                keyboardType: TextInputType.datetime),
            _buildTextField('buildingUse', '건축물 용도'),
            _buildTextField('approvalDate', '사용 승인일',
                keyboardType: TextInputType.datetime),
            _buildTextField('firstRegistrationDate', '최초 등록일',
                keyboardType: TextInputType.datetime),
            _buildTextField('options', '옵션'),
            _buildTextField('securityFacilities', '보안/안전 시설'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerProperty,
              child: const Text('매물 등록'),
            ),
          ],
        ),
      ),
    );
  }
}

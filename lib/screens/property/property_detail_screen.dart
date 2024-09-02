import 'package:flutter/material.dart';
import 'package:safe_realtor_app/models/Property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매물 상세 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${property.type} - ${property.price}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              property.description,
              style: const TextStyle(fontSize: 18),
            ),
            // 추가적인 매물 상세 정보들을 표시할 수 있습니다.
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'property/property_reg_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 버튼을 누르면 PropertyRegScreen으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PropertyRegScreen()),
            );
          },
          child: const Text('매물 등록'),
        ),
      ),
    );
  }
}

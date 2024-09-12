import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  final String userId;
  const MoreScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('더보기'),
      ),
      body: const Center(
        child: Text('더보기 화면입니다.'),
      ),
    );
  }
}

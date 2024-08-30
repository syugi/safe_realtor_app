import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Colors.blue; // 대표 색상 Teal
}

class AppStyles {
  // 공통 ElevatedButton 스타일
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor, // 버튼 배경색
    foregroundColor: Colors.white, // 버튼 텍스트 색상
    textStyle: const TextStyle(fontSize: 16), // 버튼 텍스트 스타일
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  );

  // 공통 TextButton 스타일
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primaryColor, // 버튼 텍스트 색상
    textStyle: const TextStyle(fontSize: 16),
  );

  // 공통 TextField InputDecoration 스타일
  static const InputDecoration textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
  );
}

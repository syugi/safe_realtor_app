import 'package:flutter/material.dart';
import 'dart:developer'; // 로그를 남기기 위한 패키지

// 공통 오류 메시지 표시 및 로그 남기기 함수
void showErrorMessage(BuildContext context, String message, {String? error}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
  if (error != null) {
    log('Error: $error'); // 에러 로그 남기기
  } else {
    log('Error: $message');
  }
}

// 공통 성공 메시지 표시 함수
void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
  log('Success: $message'); // 성공 로그 남기기
}

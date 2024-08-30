import 'package:flutter/material.dart';
import './screens/auth/login_screen.dart';
import 'styles/app_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppStyles.elevatedButtonStyle, // 전역 ElevatedButton 스타일
        ),
        textButtonTheme: TextButtonThemeData(
          style: AppStyles.textButtonStyle, // 전역 TextButton 스타일
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

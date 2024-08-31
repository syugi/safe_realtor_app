import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:safe_realtor_app/utils/http_status.dart';

class PhoneAuthScreen extends StatefulWidget {
  final VoidCallback onCodeVerified;

  const PhoneAuthScreen({super.key, required this.onCodeVerified});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool _isCodeSent = false;
  bool _isTimerActive = false;
  int _timerCountdown = 60 * 3;
  Timer? _timer;
  String _verificationMessage = '';

  @override
  void dispose() {
    phoneNumberController.dispose();
    codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _isCodeSent = true;
      _isTimerActive = true;
      _timerCountdown = 60 * 3;
    });

    _startTimer();

    final response = await _authService.sendCode(phoneNumberController.text);

    setState(() {
      if (response.statusCode != HttpStatus.ok) {
        _isTimerActive = false;
        _timer?.cancel();
        _verificationMessage = response.body;
      } else {
        _verificationMessage = "";
        _verificationMessage = "";
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCountdown > 0) {
          _timerCountdown--;
        } else {
          _timer?.cancel();
          _isTimerActive = false;
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _verifyCode() async {
    final response = await _authService.verifyCode(
        phoneNumberController.text, codeController.text);

    setState(() {
      if (response.statusCode == HttpStatus.ok) {
        _verificationMessage = response.body;
        widget.onCodeVerified();
      } else {
        _verificationMessage = '인증 실패: ${response.body}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: '핸드폰 번호',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: _sendCode,
              child: Text(_isCodeSent ? '재발송' : '인증번호 발송'),
            ),
            if (_isTimerActive)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _formatTime(_timerCountdown),
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (_isCodeSent) ...[
          TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: '인증번호 입력',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _verifyCode,
            child: const Text('인증번호 확인'),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          _verificationMessage,
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}

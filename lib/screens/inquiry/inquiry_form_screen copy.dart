import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inquiry_details_screen.dart'; // 상세 요청사항 페이지

class InquiryFormScreen extends StatefulWidget {
  const InquiryFormScreen({super.key});

  @override
  State<InquiryFormScreen> createState() => _InquiryFormScreenState();
}

class _InquiryFormScreenState extends State<InquiryFormScreen> {
  String? phoneNumber;
  TextEditingController inquiryController = TextEditingController();
  Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    inquiryController.text = "매물에 대해 상담 받고 싶습니다."; // 기본 문의 내용
  }

  // 사용자 전화번호 불러오기
  Future<void> _loadPhoneNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('phoneNumber') ?? '전화번호 없음';
    });
  }

  // 문의하기 클릭 시 처리
  void _onInquirySubmit() {
    if (answers.isEmpty) {
      _showQuickInquiryDialog();
    } else {
      _showInquirySummaryDialog(); // 사전 정보와 함께 요약을 보여줌
    }
  }

  // 빠른 문의하기 (상세 정보 작성 없이)
  void _showQuickInquiryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('문의하기'),
          content: const Text('상세 요청사항을 작성하시겠습니까?\n상세 요청사항은 상담에 도움이 됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('바로 문의하기'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDetailedRequest(); // 상세 요청사항 페이지로 이동
              },
              child: const Text('상세 요청사항 작성하기'),
            ),
          ],
        );
      },
    );
  }

  // 상세 요청사항 페이지로 이동
  void _navigateToDetailedRequest() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InquiryDetailsScreen(answers: answers),
      ),
    );
    if (result != null) {
      setState(() {
        answers = result; // 상세 요청사항 업데이트
      });
    }
  }

  // 문의 요약 정보 확인 다이얼로그
  void _showInquirySummaryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('문의 정보 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('문의 내용: ${inquiryController.text}'),
              const SizedBox(height: 10),
              const Text('상세 요청사항:'),
              ...answers.keys.map((key) {
                return Text('$key: ${answers[key] ?? "입력되지 않음"}');
              }),
            ],
          ),
          actions: [
            // 상세 요청사항 수정 버튼 추가
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 요약 창 닫기
                _navigateToDetailedRequest(); // 상세 요청사항 수정 페이지로 이동
              },
              child: const Text('상세 요청사항 수정'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitInquiry();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 문의 제출 처리
  void _submitInquiry() {
    print('문의 제출 완료');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문의하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 전화번호 입력 및 변경 버튼
            Row(
              children: [
                const Text('휴대폰 번호'),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: phoneNumber),
                    enabled: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _onChangePhoneNumber,
                  child: const Text('변경'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 문의 내용
            const Text('문의 내용'),
            const SizedBox(height: 10),
            TextField(
              controller: inquiryController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onInquirySubmit,
              child: const Text('문의하기'),
            ),
          ],
        ),
      ),
    );
  }

  void _onChangePhoneNumber() {
    // 전화번호 변경 화면으로 이동
  }
}

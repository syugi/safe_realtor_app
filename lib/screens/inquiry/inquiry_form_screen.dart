import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inquiry_details_screen.dart'; // 상세 요청사항 페이지
import 'package:safe_realtor_app/styles/app_styles.dart';

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
    _loadAnswersFromPreferences(); // SharedPreferences에서 상세 요청사항 불러오기
    inquiryController.text = "매물에 대해 상담 받고 싶습니다."; // 기본 문의 내용
  }

  // SharedPreferences에서 상세 요청사항 불러오기
  Future<void> _loadAnswersFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      answers = {
        '거주형태': prefs.getString('거주형태') ?? '',
        '월세 예산': prefs.getString('월세 예산') ?? '',
        '지역': prefs.getString('지역') ?? '',
        '주차': prefs.getString('주차') ?? '',
        '엘리베이터': prefs.getString('엘리베이터') ?? '',
      };
    });
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
      _confirmSubmit(); // 바로 문의 확인으로 변경
    }
  }

  // 문의 확인 다이얼로그 (문의 여부 묻기)
  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('문의하기'),
          content: const Text('문의하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // 취소
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitInquiry(); // 문의 제출
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
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

  // 문의 제출 처리
  void _submitInquiry() {
    print('문의 제출 완료'); // 여기에 실제 문의 제출 로직 추가
  }

  // 상세 요청사항 삭제 처리
  Future<void> _deleteAnswers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      answers.clear(); // 메모리에서 상세 요청사항 삭제
    });
    await prefs.remove('거주형태');
    await prefs.remove('월세 예산');
    await prefs.remove('지역');
    await prefs.remove('주차');
    await prefs.remove('엘리베이터');
    print('상세 요청사항 삭제 완료');
  }

  // 상세 요청사항 삭제 다이얼로그
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('상세 요청사항 삭제'),
          content: const Text('상세 요청사항을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAnswers(); // 상세 요청사항 삭제 처리
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
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
            // Bold 큰 글씨로 휴대폰 번호 텍스트
            const Text('휴대폰 번호', style: AppStyles.sectionTitle),
            const SizedBox(height: 10),
            // 전화번호 입력 및 변경 버튼
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: phoneNumber),
                    enabled: false,
                    decoration: AppStyles.textFieldDecoration,
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _onChangePhoneNumber,
                  style: AppStyles.roundedTextButtonStyle, // 곡선 테두리 적용
                  child: const Text('변경'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bold 큰 글씨로 문의 내용 텍스트
            const Text('문의 내용', style: AppStyles.sectionTitle),
            const SizedBox(height: 10),
            TextField(
              controller: inquiryController,
              maxLines: 5,
              decoration: AppStyles.textFieldDecoration,
            ),
            const SizedBox(height: 20),

            // 상세 요청사항 내용이 있는 경우 보여주기
            if (answers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('상세 요청사항', style: AppStyles.sectionTitle),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: _navigateToDetailedRequest,
                        icon: const Icon(Icons.edit),
                        tooltip: '상세 요청사항 수정',
                      ),
                      IconButton(
                        onPressed: _showDeleteDialog, // 삭제 아이콘 동작 추가
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: '상세 요청사항 삭제',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: answers.keys.map((key) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('$key: ${answers[key]}'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _onInquirySubmit,
                style: AppStyles.wideElevatedButtonStyle, // 넓은 버튼 스타일
                child: const Text('문의하기'),
              ),
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

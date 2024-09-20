import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InquiryDetailsScreen extends StatefulWidget {
  const InquiryDetailsScreen({super.key});

  @override
  State<InquiryDetailsScreen> createState() => _InquiryDetailsScreenState();
}

class _InquiryDetailsScreenState extends State<InquiryDetailsScreen> {
  Map<String, dynamic> answers = {};
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true; // 로딩 상태 추가
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadAnswersFromPreferences();
  }

  @override
  void dispose() {
    textController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 질문 목록을 불러오는 함수
  Future<void> _loadQuestions() async {
    try {
      final String response =
          await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        questions = data.cast<Map<String, dynamic>>();
        isLoading = false; // 로딩 완료
      });
    } catch (e) {
      print('Failed to load questions: $e');
      setState(() {
        isLoading = false; // 로딩 실패 시에도 종료
      });
    }
  }

  // SharedPreferences에서 저장된 상세 요청 사항을 불러오기
  Future<void> _loadAnswersFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAnswersJson = prefs.getString('detailed_answers');
    if (savedAnswersJson != null) {
      setState(() {
        answers = jsonDecode(savedAnswersJson);
        _updateTextController();
      });
    }
  }

// TextController를 현재 질문의 답변으로 업데이트
  void _updateTextController() {
    String questionKey = questions[currentQuestionIndex]['key'];
    textController.text = answers[questionKey] ?? '';
  }

  // 답변을 저장하는 함수 (단일 선택/다중 선택 처리)
  void _saveAnswer(String answer, bool multiSelect) {
    String key = questions[currentQuestionIndex]['key'];
    if (multiSelect) {
      List<String> selectedAnswers = answers[key]?.split(',') ?? [];
      if (selectedAnswers.contains(answer)) {
        selectedAnswers.remove(answer);
      } else {
        selectedAnswers.add(answer);
      }
      answers[key] = selectedAnswers.join(',');
    } else {
      answers[key] = answer;
    }
    setState(() {});
  }

  // 선택지가 있는 경우 버튼 UI로 출력 (다중 선택 여부에 따라 처리)
  Widget _buildOptions(
      List<dynamic>? options, String? selectedValue, bool multiSelect) {
    if (options == null) {
      return Container(); // options가 없을 경우 빈 컨테이너 반환
    }

    List<String> selectedAnswers = selectedValue?.split(',') ?? [];
    return Wrap(
      spacing: 10.0, // 버튼 간격
      children: options.map((option) {
        bool isSelected = selectedAnswers.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _saveAnswer(option, multiSelect);
            });
          },
          selectedColor: Colors.blue, // 선택된 경우 색상
          backgroundColor: Colors.grey[200], // 기본 색상
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black, // 선택된 경우 텍스트 색상
          ),
        );
      }).toList(),
    );
  }

  // SharedPreferences에 저장하는 함수
  Future<void> _saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String answersJson = jsonEncode(answers); // Map을 JSON으로 변환
    await prefs.setString('detailed_answers', answersJson);
    // 저장 후 페이지 종료
    Navigator.pop(context, answers);
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중이거나 질문 목록이 비어있을 때 처리
    if (isLoading || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('상세 요청사항')),
        body: const Center(
          child: CircularProgressIndicator(), // 로딩 중에 표시할 내용
        ),
      );
    }

    String questionKey = questions[currentQuestionIndex]['key'];
    String questionText = questions[currentQuestionIndex]['text'];
    List<dynamic>? options = questions[currentQuestionIndex]['options'];
    bool multiSelect = questions[currentQuestionIndex]['multiSelect'];
    String? selectedValue = answers[questionKey];

    return Scaffold(
      appBar: AppBar(
        title:
            Text('상세 요청사항 (${currentQuestionIndex + 1}/${questions.length})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (options != null)
              _buildOptions(
                  options, selectedValue, multiSelect) // 옵션이 있을 때 버튼 표시
            else
              TextField(
                onChanged: (value) {
                  _saveAnswer(value, multiSelect);
                },
                controller: textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                        _updateTextController(); // 이전 질문으로 이동 시 텍스트 업데이트
                      });
                    },
                    child: const Text('이전'),
                  ),
                const Spacer(),
                if (currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex++;
                        _updateTextController();
                      });
                    },
                    child: const Text('다음'),
                  )
                else
                  ElevatedButton(
                    onPressed: _saveToSharedPreferences, // 저장 버튼 클릭 시 저장
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // 버튼 텍스트 색상
                    ),
                    child: const Text('저장'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

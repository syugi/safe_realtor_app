import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InquiryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> answers;

  const InquiryDetailsScreen({super.key, required this.answers});

  @override
  State<InquiryDetailsScreen> createState() => _InquiryDetailsScreenState();
}

class _InquiryDetailsScreenState extends State<InquiryDetailsScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true; // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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

  // 답변을 저장하는 함수 (단일 선택/다중 선택 처리)
  void _saveAnswer(String answer, bool multiSelect) {
    String key = questions[currentQuestionIndex]['key'];
    if (multiSelect) {
      List<String> selectedAnswers = widget.answers[key]?.split(',') ?? [];
      if (selectedAnswers.contains(answer)) {
        selectedAnswers.remove(answer);
      } else {
        selectedAnswers.add(answer);
      }
      widget.answers[key] = selectedAnswers.join(',');
    } else {
      widget.answers[key] = answer;
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
    String answersJson = jsonEncode(widget.answers); // Map을 JSON으로 변환
    await prefs.setString('detailed_answers', answersJson);
    // 저장 후 페이지 종료
    Navigator.pop(context, widget.answers);
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
    String? selectedValue = widget.answers[questionKey];

    return Scaffold(
      appBar: AppBar(title: const Text('상세 요청사항')),
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
                controller: TextEditingController(
                  text: widget.answers[questionKey],
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    },
                    child: const Text('다음'),
                  )
                else
                  ElevatedButton(
                    onPressed: _saveToSharedPreferences, // 저장 버튼 클릭 시 저장
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

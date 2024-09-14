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

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // 질문 목록을 불러오는 함수
  Future<void> _loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      questions = data.cast<Map<String, dynamic>>();
    });
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
      List<String> options, String? selectedValue, bool multiSelect) {
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
    for (var question in questions) {
      String key = question['key'];
      String? value = widget.answers[key];
      if (value != null) {
        prefs.setString(key, value);
      }
    }
    // 저장 후 페이지 종료
    Navigator.pop(context, widget.answers);
  }

  @override
  Widget build(BuildContext context) {
    String questionKey = questions[currentQuestionIndex]['key'];
    String questionText = questions[currentQuestionIndex]['text'];
    List<String>? options = questions[currentQuestionIndex]['options'];
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

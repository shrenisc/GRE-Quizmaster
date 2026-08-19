import 'package:flutter/material.dart';
import '../../data/models/exam_question.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class ExamModeView extends StatefulWidget {
  const ExamModeView({Key? key}) : super(key: key);

  @override
  _ExamModeViewState createState() => _ExamModeViewState();
}

class _ExamModeViewState extends State<ExamModeView> {
  final ExamRepository _examRepo = ExamRepository();
  final ProgressRepository _progressRepo = ProgressRepository();
  
  List<ExamQuestion> _questions = [];
  int _currentIndex = 0;
  bool _answered = false;
  int _score = 0;
  bool _examFinished = false;
  
  // For single choice
  int _selectedOptionIndex = -1;
  // For multi choice
  Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _startExam();
  }

  void _startExam() {
    setState(() {
      _questions = _examRepo.generateExam();
      _currentIndex = 0;
      _score = 0;
      _examFinished = false;
      _resetSelection();
    });
  }

  void _resetSelection() {
    _answered = false;
    _selectedOptionIndex = -1;
    _selectedIndices.clear();
  }

  void _selectOption(int index) {
    if (_answered) return;
    
    setState(() {
      final question = _questions[_currentIndex];
      if (question.isSentenceEquivalence) {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          if (_selectedIndices.length < 2) {
            _selectedIndices.add(index);
          }
        }
      } else {
        _selectedOptionIndex = index;
        _submitAnswer();
      }
    });
  }

  void _submitAnswer() {
    if (_answered) return;
    final question = _questions[_currentIndex];
    
    if (question.isSentenceEquivalence && _selectedIndices.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 2 options.')),
      );
      return;
    }

    setState(() {
      _answered = true;
      if (question.isSentenceEquivalence) {
        bool correct = true;
        for (int idx in _selectedIndices) {
          if (!question.correctIndices.contains(idx)) correct = false;
        }
        if (correct && _selectedIndices.length == question.correctIndices.length) {
          _score++;
        }
      } else {
        if (question.correctIndices.contains(_selectedOptionIndex)) {
          _score++;
        }
      }
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _resetSelection();
      });
    } else {
      final currentProgress = await _progressRepo.getProgress();
      final newProgress = currentProgress.copyWith(
        xp: currentProgress.xp + (_score * 20), // Exams give more XP
        lastActive: DateTime.now(),
      );
      await _progressRepo.saveProgress(newProgress);

      setState(() {
        _examFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam Mode'), backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Not enough words to generate an exam. Please practice more!')),
      );
    }

    if (_examFinished) {
      return _buildSummaryScreen();
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(question.isSentenceEquivalence ? 'Sentence Equivalence' : 'Text Completion'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Center(
                  child: Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (question.isSentenceEquivalence)
                Text('Select exactly 2 words', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange.shade800)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    bool isCorrect = question.correctIndices.contains(index);
                    bool isSelected = question.isSentenceEquivalence
                        ? _selectedIndices.contains(index)
                        : index == _selectedOptionIndex;
                    
                    Color buttonColor = Colors.white;
                    if (_answered) {
                      if (isCorrect) buttonColor = Colors.green.shade100;
                      else if (isSelected) buttonColor = Colors.red.shade100;
                    } else if (isSelected) {
                      buttonColor = Colors.blue.shade50;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => _selectOption(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.grey.shade400 : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (question.isSentenceEquivalence) ...[
                                Icon(
                                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: isSelected ? Colors.black87 : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!_answered && question.isSentenceEquivalence) ...[
                const SizedBox(height: 16),
                NeonButton(
                  label: 'Submit Answer',
                  onPressed: _selectedIndices.length == 2 ? _submitAnswer : null,
                ),
              ],
              if (_answered) ...[
                const SizedBox(height: 16),
                NeonButton(
                  label: _currentIndex < _questions.length - 1 ? 'Next Question' : 'Finish Exam',
                  onPressed: _nextQuestion,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Complete'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GlassCard(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Exam Finished!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Score: $_score / ${_questions.length}',
                  style: const TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                NeonButton(
                  label: 'Retake Exam',
                  onPressed: _startExam,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Dashboard', style: TextStyle(fontSize: 18, color: Colors.grey.shade800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/vocab_word.dart';
import '../../data/repositories/vocab_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class ReviewQueueView extends StatefulWidget {
  const ReviewQueueView({Key? key}) : super(key: key);

  @override
  _ReviewQueueViewState createState() => _ReviewQueueViewState();
}

class _ReviewQueueViewState extends State<ReviewQueueView> {
  final VocabRepository _vocabRepo = VocabRepository();
  final ProgressRepository _progressRepo = ProgressRepository();
  
  List<VocabWord> _words = [];
  List<VocabWord> _allWords = [];
  int _currentIndex = 0;
  bool _answered = false;
  bool _drillFinished = false;
  bool _isLoading = true;
  
  List<String> _currentOptions = [];
  int _correctOptionIndex = 0;
  int _selectedOptionIndex = -1;

  @override
  void initState() {
    super.initState();
    _allWords = _vocabRepo.getAllWords();
    _loadMissedWords();
  }

  Future<void> _loadMissedWords() async {
    final missedWordsStrs = await _progressRepo.getMissedWords();
    final List<VocabWord> missed = [];
    
    for (final wordStr in missedWordsStrs) {
      try {
        final w = _allWords.firstWhere((element) => element.word == wordStr);
        missed.add(w);
      } catch (e) {
        // Word not found
      }
    }
    
    missed.shuffle();
    
    setState(() {
      _words = missed;
      _isLoading = false;
      if (_words.isNotEmpty) {
        _startDrill();
      }
    });
  }

  void _startDrill() {
    setState(() {
      _currentIndex = 0;
      _drillFinished = false;
    });
    _generateOptions();
  }

  void _generateOptions() {
    if (_words.isEmpty || _currentIndex >= _words.length) return;
    
    final currentWord = _words[_currentIndex];
    final random = Random();
    final wrongWords = _allWords.where((w) => w.word != currentWord.word).toList();
    wrongWords.shuffle();
    
    final options = <String>[currentWord.definition];
    for (int i = 0; i < 3 && i < wrongWords.length; i++) {
      options.add(wrongWords[i].definition);
    }
    
    options.shuffle();
    _currentOptions = options;
    _correctOptionIndex = options.indexOf(currentWord.definition);
    _answered = false;
    _selectedOptionIndex = -1;
  }

  void _selectOption(int index) async {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
    });
    
    if (index == _correctOptionIndex) {
      await _progressRepo.removeMissedWord(_words[_currentIndex].word);
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateOptions();
    } else {
      setState(() {
        _drillFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Queue'), backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('No missed words to review! Great job!')),
      );
    }

    if (_drillFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Complete'), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Review Complete!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 24),
              NeonButton(label: 'Back to Home', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Queue'),
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
                '${_currentIndex + 1} / ${_words.length}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: Center(
                  child: Text(
                    currentWord.word,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: _currentOptions.length,
                  itemBuilder: (context, index) {
                    bool isCorrect = index == _correctOptionIndex;
                    bool isSelected = index == _selectedOptionIndex;
                    
                    Color buttonColor = Colors.white;
                    if (_answered) {
                      if (isCorrect) buttonColor = Colors.green.shade100;
                      else if (isSelected) buttonColor = Colors.red.shade100;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => _selectOption(index),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.grey.shade400 : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            _currentOptions[index],
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_answered) ...[
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (currentWord.synonyms.isNotEmpty)
                        Text('Synonyms: ${currentWord.synonyms}', style: TextStyle(color: Colors.orange.shade800, fontStyle: FontStyle.italic)),
                      if (currentWord.exampleSentence.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Usage: "${currentWord.exampleSentence}"', style: TextStyle(color: Colors.grey.shade800)),
                        ),
                      if (currentWord.synonyms.isEmpty && currentWord.exampleSentence.isEmpty)
                        Text('Correct definition highlighted.', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: _currentIndex < _words.length - 1 ? 'Next Word' : 'Finish Review',
                  onPressed: _nextQuestion,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

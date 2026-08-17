import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/vocab_word.dart';
import '../../data/repositories/vocab_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';

class GroupDrillView extends StatefulWidget {
  final int groupId;

  const GroupDrillView({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDrillViewState createState() => _GroupDrillViewState();
}

class _GroupDrillViewState extends State<GroupDrillView> {
  final VocabRepository _vocabRepo = VocabRepository();
  final ProgressRepository _progressRepo = ProgressRepository();
  
  List<VocabWord> _words = [];
  List<VocabWord> _allWords = [];
  int _currentIndex = 0;
  bool _answered = false;
  int _score = 0;
  bool _drillFinished = false;
  
  List<String> _currentOptions = [];
  int _correctOptionIndex = 0;
  int _selectedOptionIndex = -1;

  @override
  void initState() {
    super.initState();
    _allWords = _vocabRepo.getAllWords();
    _startDrill();
  }

  void _startDrill() {
    setState(() {
      _words = _vocabRepo.getWordsForGroup(widget.groupId);
      _words.shuffle();
      _currentIndex = 0;
      _score = 0;
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

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (index == _correctOptionIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() async {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateOptions();
    } else {
      // Save score
      await _progressRepo.saveGroupScore(widget.groupId, _score);
      setState(() {
        _drillFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) return const Scaffold(body: Center(child: Text('No words found.')));

    if (_drillFinished) {
      return _buildSummaryScreen();
    }

    final currentWord = _words[_currentIndex];

    return WillPopScope(
      onWillPop: () async {
        if (!_drillFinished) {
          await _progressRepo.saveGroupScore(widget.groupId, _score);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Drill: Group ${widget.groupId}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (!_drillFinished) {
                await _progressRepo.saveGroupScore(widget.groupId, _score);
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
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
                style: const TextStyle(color: Colors.white54),
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
                    
                    Color buttonColor = Colors.white.withOpacity(0.1);
                    if (_answered) {
                      if (isCorrect) {
                        buttonColor = Colors.green.withOpacity(0.6);
                      } else if (isSelected) {
                        buttonColor = Colors.red.withOpacity(0.6);
                      }
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
                              color: isSelected ? Colors.white : Colors.white24,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            _currentOptions[index],
                            style: const TextStyle(fontSize: 16),
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
                        Text(
                          'Synonyms: ${currentWord.synonyms}',
                          style: const TextStyle(color: Colors.orangeAccent, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      if (currentWord.exampleSentence.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Usage: "${currentWord.exampleSentence}"',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (currentWord.synonyms.isEmpty && currentWord.exampleSentence.isEmpty)
                        const Text('Correct definition shown in green.', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: _currentIndex < _words.length - 1 ? 'Next Word' : 'Finish Drill',
                  onPressed: _nextQuestion,
                ),
              ]
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSummaryScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Complete'),
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
                  'Group Complete!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your Score: $_score / ${_words.length}',
                  style: const TextStyle(fontSize: 24, color: Colors.blueAccent),
                ),
                const SizedBox(height: 40),
                NeonButton(
                  label: 'Replay Group',
                  onPressed: _startDrill,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Groups', style: TextStyle(fontSize: 18, color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

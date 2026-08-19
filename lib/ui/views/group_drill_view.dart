import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/vocab_word.dart';
import '../../data/repositories/vocab_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/neon_button.dart';
import '../theme/app_theme.dart';
import 'package:confetti/confetti.dart';

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

  bool _isLoading = true;
  int _sessionScore = 0;
  Set<String> _wordsGottenWrong = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _allWords = _vocabRepo.getAllWords();
    _startDrill();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _startDrill() async {
    setState(() {
      _isLoading = true;
      _score = 0;
      _sessionScore = 0;
      _drillFinished = false;
      _wordsGottenWrong.clear();
    });

    final remainingWordStrings = await _progressRepo.getIncompleteDrill(widget.groupId);

    setState(() {
      if (remainingWordStrings != null && remainingWordStrings.isNotEmpty) {
        // Resume drill
        _words = remainingWordStrings.map((wStr) {
          return _allWords.firstWhere((w) => w.word == wStr, orElse: () => _allWords.first);
        }).toList();
        // Fetch partial score
        _progressRepo.getGroupScore(widget.groupId).then((savedScore) {
          if (mounted) setState(() => _score = savedScore);
        });
      } else {
        // New drill
        _words = _vocabRepo.getWordsForGroup(widget.groupId);
        _words.shuffle();
      }
      
      _currentIndex = 0;
      _isLoading = false;
    });
    
    _generateOptions();
  }

  Future<bool> _handleSave() async {
    if (!_drillFinished) {
      final remainingWords = _words.sublist(_currentIndex).map((w) => w.word).toList();
      await _progressRepo.saveIncompleteDrill(widget.groupId, remainingWords, _score);

      final currentProgress = await _progressRepo.getProgress();
      final newProgress = currentProgress.copyWith(
        xp: currentProgress.xp + (_sessionScore * 10),
        lastActive: DateTime.now(),
      );
      await _progressRepo.saveProgress(newProgress);
    }
    return true; // Allow pop
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
      
      final currentWord = _words[_currentIndex];
      if (index == _correctOptionIndex) {
        if (!_wordsGottenWrong.contains(currentWord.word)) {
          _score++;
          _sessionScore++;
        }
      } else {
        _progressRepo.addMissedWord(currentWord.word);
        _wordsGottenWrong.add(currentWord.word);
        
        // Re-insert this word randomly later in the queue
        final remainingCount = _words.length - 1 - _currentIndex;
        if (remainingCount > 0) {
          final insertIndex = Random().nextInt(remainingCount) + _currentIndex + 1;
          _words.insert(insertIndex, currentWord);
        } else {
          _words.add(currentWord);
        }
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
      // Save score (this will also clear the incomplete drill)
      await _progressRepo.saveGroupScore(widget.groupId, _score);
      
      // Update overall XP
      final currentProgress = await _progressRepo.getProgress();
      final newProgress = currentProgress.copyWith(
        xp: currentProgress.xp + (_sessionScore * 10), // 10 XP per correct word this session
        lastActive: DateTime.now(),
      );
      await _progressRepo.saveProgress(newProgress);

      setState(() {
        _drillFinished = true;
      });
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_words.isEmpty) return const Scaffold(body: Center(child: Text('No words found.')));

    if (_drillFinished) {
      return _buildSummaryScreen();
    }

    final currentWord = _words[_currentIndex];

    return WillPopScope(
      onWillPop: _handleSave,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Group ${widget.groupId} Drill'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save & Exit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                await _handleSave();
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: GlassCard(
                    key: ValueKey<int>(_currentIndex),
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Center(
                      child: Text(
                        currentWord.word,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                        textAlign: TextAlign.center,
                      ),
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
                        if (isCorrect) {
                          buttonColor = Colors.green.shade100;
                        } else if (isSelected) {
                          buttonColor = Colors.red.shade100;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.grey.shade400 : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _selectOption(index),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _currentOptions[index],
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_answered) ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (currentWord.synonyms.isNotEmpty)
                            Text(
                              'Synonyms: ${currentWord.synonyms}',
                              style: TextStyle(color: Colors.orange.shade800, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          if (currentWord.exampleSentence.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Usage: "${currentWord.exampleSentence}"',
                                style: TextStyle(color: Colors.grey.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (currentWord.synonyms.isEmpty && currentWord.exampleSentence.isEmpty)
                            Text('Correct definition highlighted.', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: NeonButton(
                      label: _currentIndex < _words.length - 1 ? 'Next Word' : 'Finish Drill',
                      onPressed: _nextQuestion,
                    ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
          alignment: Alignment.center,
          children: [
            Center(
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
                        style: const TextStyle(fontSize: 24, color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      NeonButton(
                        label: 'Replay Group',
                        onPressed: _startDrill,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Back to Groups', style: TextStyle(fontSize: 18, color: Colors.grey.shade800)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ),
          ],
      ),
    );
  }
}

import 'dart:math';
import '../models/exam_question.dart';
import 'vocab_repository.dart';

class ExamRepository {
  final VocabRepository _vocabRepo = VocabRepository();

  List<ExamQuestion> generateExam() {
    final allWords = _vocabRepo.getAllWords();
    if (allWords.length < 8) return []; // Not enough data
    
    final random = Random();
    final examWords = List.of(allWords)..shuffle(random);
    final selectedWords = examWords.take(8).toList();
    
    List<ExamQuestion> questions = [];
    
    // Generate 5 Text Completion (Single Choice)
    for (int i = 0; i < 5; i++) {
      final word = selectedWords[i];
      final wrongWords = allWords.where((w) => w.word != word.word).toList()..shuffle(random);
      
      final options = [word.definition];
      for (int j = 0; j < 3; j++) {
        options.add(wrongWords[j].definition);
      }
      options.shuffle(random);
      
      questions.add(ExamQuestion(
        questionText: 'Select the definition for "${word.word}":',
        options: options,
        correctIndices: [options.indexOf(word.definition)],
        groupId: 0,
      ));
    }
    
    // Generate 3 Sentence Equivalence (Multi-Choice)
    for (int i = 5; i < 8; i++) {
      final word = selectedWords[i];
      final wrongWords = allWords.where((w) => w.word != word.word).toList()..shuffle(random);
      
      // Since our words might not have enough synonyms, we'll ask for two words that mean the definition
      // But wait, the app is structured as 'word' -> definition. 
      // Let's ask: "Select two words that mean: [definition]"
      // Options will be: The correct word, another word with a similar definition (mocked by picking random correct if we don't have synonyms as separate words),
      // Actually, we can use the `synonyms` field. But wait, `synonyms` is a string like "severe, strict, harsh".
      // Let's just make the options 6 words. 2 are correct (the word itself, and we'll split the synonyms string to pick one).
      final syns = word.synonyms.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      String correctSynonym = syns.isNotEmpty ? syns.first : word.word; // Fallback
      
      final options = [word.word];
      if (syns.isNotEmpty) options.add(correctSynonym);
      
      // Fill the rest with wrong words
      for (int j = 0; options.length < 6; j++) {
        if (!options.contains(wrongWords[j].word)) {
          options.add(wrongWords[j].word);
        }
      }
      options.shuffle(random);
      
      List<int> correctIndices = [];
      for (int j = 0; j < options.length; j++) {
        if (options[j] == word.word || options[j] == correctSynonym) {
          correctIndices.add(j);
        }
      }
      
      questions.add(ExamQuestion(
        questionText: 'Select two words that mean:\n"${word.definition}"',
        options: options,
        correctIndices: correctIndices,
        groupId: 0,
        isSentenceEquivalence: true,
      ));
    }
    
    return questions;
  }
}

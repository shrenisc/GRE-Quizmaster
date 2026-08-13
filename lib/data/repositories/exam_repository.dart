import '../models/exam_question.dart';

class ExamRepository {
  List<ExamQuestion> getQuestionsForGroup(int groupId) {
    return [
      ExamQuestion(
        questionText: 'Which of the following best describes the word "abate"?',
        options: ['To become less intense', 'To increase in intensity', 'To maintain the same level', 'To start suddenly'],
        correctIndices: [0],
        groupId: groupId,
      ),
      ExamQuestion(
        questionText: 'Select two synonyms for "aberration".',
        options: ['Normality', 'Anomaly', 'Deviation', 'Consistency', 'Regularity', 'Standard'],
        correctIndices: [1, 2],
        groupId: groupId,
        isSentenceEquivalence: true,
      ),
    ];
  }
}

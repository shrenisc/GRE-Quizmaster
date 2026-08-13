class ExamQuestion {
  final String questionText;
  final List<String> options;
  final List<int> correctIndices;
  final int groupId;
  final bool isSentenceEquivalence;

  const ExamQuestion({
    required this.questionText,
    required this.options,
    required this.correctIndices,
    required this.groupId,
    this.isSentenceEquivalence = false,
  });
}

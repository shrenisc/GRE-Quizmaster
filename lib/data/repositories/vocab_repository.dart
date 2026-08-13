import '../models/vocab_word.dart';
import '../vocab_data.dart';

class VocabRepository {
  List<VocabWord> getWordsForGroup(int groupId) {
    return allVocabWords.where((word) => word.groupId == groupId).toList();
  }
  
  List<VocabWord> getAllWords() {
    return allVocabWords;
  }
}

import 'package:flutter/material.dart';
import '../../data/repositories/progress_repository.dart';
import '../widgets/glass_card.dart';

class GroupListView extends StatefulWidget {
  const GroupListView({Key? key}) : super(key: key);

  @override
  _GroupListViewState createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  final ProgressRepository _progressRepo = ProgressRepository();

  void _refreshScores() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocab Groups'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 32, // We have 32 groups
        itemBuilder: (context, index) {
          final groupId = index + 1;
          return FutureBuilder<GroupProgressState>(
            future: _progressRepo.getGroupProgressState(groupId),
            builder: (context, snapshot) {
              final state = snapshot.data;
              final score = state?.score ?? 0;
              final remaining = state?.remainingWordsCount ?? 0;

              String subtitleText;
              if (remaining > 0) {
                // If there are remaining words, it means they are currently attempting it
                final completedCount = 30 - remaining;
                subtitleText = 'Attempting ($completedCount / 30)';
              } else {
                subtitleText = 'Score: $score / 30';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  child: ListTile(
                    title: Text('Group $groupId', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitleText, style: TextStyle(
                      color: remaining > 0 ? Colors.orangeAccent : Colors.white70,
                      fontWeight: remaining > 0 ? FontWeight.bold : FontWeight.normal,
                    )),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                    onTap: () async {
                      await Navigator.pushNamed(context, '/drill', arguments: groupId);
                      _refreshScores();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

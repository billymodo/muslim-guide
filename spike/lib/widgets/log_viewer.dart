import 'package:flutter/material.dart';

/// عارض سجل عمليات Spike — يعرض الأحدث أعلى القائمة.
class LogViewer extends StatelessWidget {
  /// Creates a log viewer over the given [entries].
  const new({required this.entries, super.key});

  /// أسطر السجل (الأحدث أولًا).
  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return Text(
          entries[index],
          style: const TextStyle(fontSize: 12),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

/// تطبيق Spike لـ Phase 00B — يُحذف قبل اعتماد المرحلة (legal/policy.yaml).
void main() {
  runApp(const SpikeApp());
}

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spike 00B',
      home: Scaffold(
        appBar: AppBar(title: const Text('Spike 00B')),
        body: const Center(child: Text('السيناريوهات تُضاف في الخطوة 5')),
      ),
    );
  }
}

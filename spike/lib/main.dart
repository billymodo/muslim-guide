import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:muslim_guide_spike/services/audio_service_handler.dart';
import 'package:muslim_guide_spike/services/hive_isolate_test.dart';
import 'package:muslim_guide_spike/services/notification_service.dart';
import 'package:muslim_guide_spike/widgets/log_viewer.dart';

/// نقطة الدخول — تهيّئ خدمة الصوت ثم تشغّل واجهة Spike.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handler = await AudioService.init(
    builder: SpikeAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'spike.audio.channel',
      androidNotificationChannelName: 'Spike 00B audio',
    ),
  );
  runApp(SpikeApp(handler: handler));
}

/// تطبيق Spike — واجهة اختبار Phase 00B (تُحذف بعد الاعتماد).
class SpikeApp extends StatelessWidget {
  /// Creates the spike shell; [handler] اختياري (null في الاختبار).
  const new({required this.handler, super.key});

  /// معالج الصوت — null في اختبارات الواجهة (Option A، 2026-10-06).
  final SpikeAudioHandler? handler;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpikeHomePage(handler: handler),
    );
  }
}

/// الصفحة الرئيسية: ثلاثة أزرار اختبار + سجل عمليات حيّ.
class SpikeHomePage extends StatefulWidget {
  /// Creates the home page; [handler] null يعطل زر الصوت فقط.
  const new({required this.handler, super.key});

  /// معالج الصوت المستخدم في زر التشغيل (اختياري).
  final SpikeAudioHandler? handler;

  @override
  State<SpikeHomePage> createState() => _SpikeHomePageState();
}

class _SpikeHomePageState extends State<SpikeHomePage> {
  final NotificationService _notifications = NotificationService();
  final HiveIsolateTest _hiveTest = HiveIsolateTest();
  final List<String> _log = <String>[];

  void _addLog(String operation, String result, String message) {
    final now = DateTime.now().toIso8601String();
    setState(() {
      _log.insert(0, '[$now] $operation | $result | $message');
    });
  }

  Future<void> _scheduleNotification() async {
    try {
      await _notifications.init();
      await _notifications.scheduleIn(30);
      _addLog('جدولة إشعار', 'نجاح', 'بعد 30 ثانية (exact)');
    } on Exception catch (e) {
      _addLog('جدولة إشعار', 'فشل', '$e');
    }
  }

  Future<void> _playAudio() async {
    final handler = widget.handler;
    if (handler == null) {
      return;
    }
    try {
      await handler.playBeepFor(const Duration(seconds: 10));
      _addLog('صوت خلفي', 'نجاح', 'beep.wav ×10s');
    } on Exception catch (e) {
      _addLog('صوت خلفي', 'فشل', '$e');
    }
  }

  Future<void> _runHiveTest() async {
    try {
      final result = await _hiveTest.run();
      _addLog(
        'Hive isolate',
        result.ok ? 'نجاح' : 'فشل',
        result.message,
      );
    } on Exception catch (e) {
      _addLog('Hive isolate', 'خطأ', '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spike 00B')),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: const Text('جدولة إشعار بعد 30 ثانية'),
            ),
            ElevatedButton(
              onPressed: widget.handler == null ? null : _playAudio,
              child: const Text('تشغيل صوت 10 ثوانٍ'),
            ),
            ElevatedButton(
              onPressed: _runHiveTest,
              child: const Text('اختبار Hive من isolate'),
            ),
            const Divider(height: 24),
            Expanded(
              child: LogViewer(entries: _log),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// معالج صوت Spike — يتبع README الرسمي لـ audio_service 0.18.19.
class SpikeAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  /// Creates the handler; [player] يسمح بالإقلاع في الاختبارات.
  new({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// يشغّل beep.wav من الأصول بحلقة متكررة ثم يتوقف بعد [duration].
  Future<void> playBeepFor(Duration duration) async {
    await _player.setAsset('beep.wav');
    await _player.setLoopMode(LoopMode.all);
    unawaited(_player.play());
    await Future<void>.delayed(duration);
    await _player.stop();
    await _player.setLoopMode(LoopMode.off);
  }

  /// تشغيل (واجهة AudioHandler).
  @override
  Future<void> play() => _player.play();

  /// إيقاف مؤقت (واجهة AudioHandler).
  @override
  Future<void> pause() => _player.pause();

  /// إيقاف نهائي (واجهة AudioHandler).
  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  /// تحديد موضع التشغيل (واجهة AudioHandler).
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// تحرير موارد المشغّل.
  Future<void> dispose() => _player.dispose();
}

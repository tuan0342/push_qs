import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class Fmp4UrlPlayer extends StatefulWidget {
  /// URL fMP4 dạng:
  /// http://localhost:9996/get?path=[mypath]&start=...&duration=60.0
  final String url;

  /// Tổng thời lượng dự kiến của clip (theo tham số duration trên URL).
  /// Nếu player đọc ra duration thật, component sẽ tự dùng duration thật.
  final Duration expectedDuration;

  /// Bật tự play khi mở (mặc định: true)
  final bool autoPlay;

  const Fmp4UrlPlayer({
    super.key,
    required this.url,
    required this.expectedDuration,
    this.autoPlay = true,
  });

  @override
  State<Fmp4UrlPlayer> createState() => _Fmp4UrlPlayerState();
}

class _Fmp4UrlPlayerState extends State<Fmp4UrlPlayer> {
  late final Player _player;
  late final VideoController _video;

  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<String>? _errSub;

  @override
  void initState() {
    super.initState();

    _player = Player();
    _video = VideoController(_player);

    // tổng thời lượng fallback = expectedDuration
    _total = widget.expectedDuration;

    // Lắng nghe vị trí & tổng thời lượng
    _posSub = _player.stream.position.listen((p) {
      setState(() => _position = p);
    });
    _durSub = _player.stream.duration.listen((d) {
      // Một số nguồn mạng có thể không trả duration; nếu trả, ưu tiên dùng
      if (d > Duration.zero) {
        setState(() => _total = d);
      }
    });
    _errSub = _player.stream.error.listen((e) {
      debugPrint('media_kit error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback error: $e')),
      );
    });

    // Mở URL
    _player.open(Media(widget.url), play: widget.autoPlay);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _errSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final canSeek = _total > Duration.zero;

    return Column(
      children: [
        // Video
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Video(
              controller: _video,
              controls: null, // ta tự làm controls phía dưới
            ),
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            children: [
              // Seek bar
              Row(
                children: [
                  Text(_fmt(_position)),
                  Expanded(
                    child: Slider(
                      value: _position.inMilliseconds
                          .clamp(0, _total.inMilliseconds)
                          .toDouble(),
                      min: 0,
                      max: (_total.inMilliseconds == 0
                              ? 1
                              : _total.inMilliseconds)
                          .toDouble(),
                      onChanged: canSeek
                          ? (v) => setState(
                              () => _position = Duration(milliseconds: v.round()))
                          : null,
                      onChangeEnd: canSeek
                          ? (v) => _player.seek(
                                Duration(milliseconds: v.round()),
                              )
                          : null,
                    ),
                  ),
                  Text(_fmt(_total)),
                ],
              ),

              // Play/Pause, Stop, Mute/Vol, Speed
              Row(
                children: [
                  StreamBuilder<bool>(
                    stream: _player.stream.playing,
                    initialData: false,
                    builder: (context, snap) {
                      final playing = snap.data ?? false;
                      return IconButton.filled(
                        onPressed: _player.playOrPause,
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      await _player.stop();
                      setState(() => _position = Duration.zero);
                    },
                    icon: const Icon(Icons.stop),
                  ),
                  const SizedBox(width: 12),

                  // Volume + mute toggle
                  StreamBuilder<double>(
                    stream: _player.stream.volume,
                    initialData: 100.0,
                    builder: (context, snap) {
                      final vol = snap.data ?? 100.0;
                      final isMuted = vol <= 0.0;
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                _player.setVolume(isMuted ? 100.0 : 0.0),
                            icon: Icon(isMuted
                                ? Icons.volume_off
                                : Icons.volume_up),
                          ),
                          SizedBox(
                            width: 140,
                            child: Slider(
                              value: vol,
                              min: 0,
                              max: 100,
                              onChanged: (v) => _player.setVolume(v),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(),

                  // Playback rate
                  StreamBuilder<double>(
                    stream: _player.stream.rate,
                    initialData: 1.0,
                    builder: (context, snap) {
                      final rate = snap.data ?? 1.0;
                      return DropdownButton<double>(
                        value: rate,
                        onChanged: (v) => v == null ? null : _player.setRate(v),
                        items: const [0.5, 1.0, 1.5, 2.0]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('${e}x'),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

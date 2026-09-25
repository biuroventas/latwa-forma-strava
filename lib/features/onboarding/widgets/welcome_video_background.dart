import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Tło welcome na telefonie: sam film w pętli, bez dźwięku.
///
/// Jeden odtwarzacz: tył `cover` (ten sam kadr), rozmywany co klatkę
/// przez [BackdropFilter], przód `contain` (ostry, cały kadr).
/// Zanim film wstanie, widać tylko kolor tła — bez osobnego obrazka.
class WelcomeVideoBackground extends StatefulWidget {
  const WelcomeVideoBackground({super.key});

  @override
  State<WelcomeVideoBackground> createState() => _WelcomeVideoBackgroundState();
}

class _WelcomeVideoBackgroundState extends State<WelcomeVideoBackground> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/scenavideo.mp4');
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _ready = true);
    } catch (_) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _controller = null;
          _ready = false;
        });
      } else {
        _controller = null;
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  Widget _fittedVideo(
    VideoPlayerController controller,
    BoxFit fit, {
    bool fadeTop = false,
    double bottomFeather = 0,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    final videoSize = controller.value.size;
    Widget player = VideoPlayer(controller);
    if (fadeTop || bottomFeather > 0) {
      final end = (1 - bottomFeather).clamp(0.2, 1.0);
      final colors = <Color>[
        const Color(0x00000000),
        const Color(0x59000000),
        const Color(0xFF000000),
        const Color(0xFF000000),
      ];
      final stops = <double>[0, 0.05, 0.12, end];
      if (bottomFeather > 0) {
        colors.add(const Color(0x00000000));
        stops.add(1);
      }
      player = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ).createShader(bounds),
        child: player,
      );
    }
    return FittedBox(
      fit: fit,
      clipBehavior: clipBehavior,
      child: SizedBox(
        width: videoSize.width,
        height: videoSize.height,
        child: player,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = _ready &&
        controller != null &&
        controller.value.isInitialized &&
        controller.value.size.width > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = Size(constraints.maxWidth, constraints.maxHeight);
        final active = ready ? controller : null;
        final videoSize = active != null ? active.value.size : Size.zero;
        final fitted = active != null ? applyBoxFit(BoxFit.contain, videoSize, screen) : null;
        final dest = fitted?.destination ?? Size.zero;
        final videoTop = (screen.height - dest.height) / 2;
        final videoLeft = (screen.width - dest.width) / 2;
        final edge = videoTop + dest.height;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (active != null && fitted != null) ...[
              Positioned.fill(
                child: _fittedVideo(active, BoxFit.cover),
              ),
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              ),
              if (edge < screen.height)
                Positioned(
                  left: videoLeft,
                  width: dest.width,
                  top: edge,
                  height: dest.height,
                  child: ClipRect(
                    child: Transform.flip(
                      flipY: true,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: SizedBox(
                          width: videoSize.width,
                          height: videoSize.height,
                          child: VideoPlayer(active),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: _fittedVideo(active, BoxFit.contain, fadeTop: true),
              ),
            ],
          ],
        );
      },
    );
  }
}

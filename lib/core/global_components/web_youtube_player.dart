import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as iframe;

/// YouTube player for Flutter web.
///
/// `youtube_player_flutter` is WebView based and has no web implementation, so
/// web builds use the iframe player instead.
class WebYoutubePlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;

  const WebYoutubePlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
  });

  @override
  State<WebYoutubePlayer> createState() => _WebYoutubePlayerState();
}

class _WebYoutubePlayerState extends State<WebYoutubePlayer> {
  late final iframe.YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = iframe.YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: widget.autoPlay,
      params: const iframe.YoutubePlayerParams(
        showFullscreenButton: true,
        captionLanguage: 'id',
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return iframe.YoutubePlayer(controller: _controller);
  }
}

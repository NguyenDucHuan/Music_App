import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/data/model/song.dart';

import 'audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(playingSong: playingSong, songs: songs);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 12));
    _audioPlayerManager =AudioPlayerManager(songUrl: widget.playingSong.source);
    _audioPlayerManager.init();
  }

  @override
  Widget build(BuildContext context) {
    // Cấu hình cho ảnh
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "NowPlaying",
        ),
        trailing:
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.playingSong.album),
              const Text('-------'),
              Text('Mã Bài  ${widget.playingSong.id}'),
              const SizedBox(
                height: 20,
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/logo.jpg',
                    image: widget.playingSong.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/logo.jpg",
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    }, // imageErrorBuilder
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                          weight: 900,
                        ),
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                      ),
                      Column(
                        children: [
                          Text(
                            widget.playingSong.title,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                          ),
                          Text(
                            widget.playingSong.artist,
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite_border,
                          weight: 700,
                        ),
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                      )
                    ],
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 24
              ),
                child: _progessBar(),
              )
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<DurationState> _progessBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder:(context , snapshot){
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(progress: progress, total: total, );
        });
  }
}

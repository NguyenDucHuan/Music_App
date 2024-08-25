import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  late int _selectedItemIndex;
  late Song _song;
  late LoopMode _loopMode;
  double _curenAnimationPosition = 0.0;
  bool _isshuffle = false;

  @override
  void initState() {
    super.initState();
    _imageAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _audioPlayerManager =
        AudioPlayerManager(songUrl: widget.playingSong.source);
    _audioPlayerManager.init();
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _song = widget.playingSong;
    _loopMode = LoopMode.off;
    _audioPlayerManager.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongComplete();
      }
    });
  }
  void _onSongComplete() {
    // When the current song is completed, play the next song
    _setNextSong();
  }
  @override
  void dispose() {
    _audioPlayerManager.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cấu hình cho ảnh
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "NowPlaying",
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_song.album),
              const Text('-------'),
              Text('Mã Bài  ${_song.id}'),
              const SizedBox(
                height: 30,
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0)
                    .animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/logo.jpg',
                    image: _song.image,
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
                padding: const EdgeInsets.only(top: 30, bottom: 30),
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                          ),
                          Text(
                            _song.artist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
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
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ), // Title
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 24, right: 24, bottom: 10),
                child: _progessBar(),
              ), // ProgressBar
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                child: _mediaButton(),
              ) //MediaButtonController
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonController(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 30),
          MediaButtonController(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.purpleAccent,
              size: 30),
          _playingButton(),
          MediaButtonController(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.purpleAccent,
              size: 30),
          MediaButtonController(
              function: _setRepeatOption,
              icon: _repeatingIcon(),
              color: _getReapetColor(),
              size: 24),
        ],
      ),
    );
  }

  Color? _getReapetColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.purpleAccent;
  }

  void _setRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat
    };
  }

  StreamBuilder<DurationState> _progessBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 3.0,
            barCapShape: BarCapShape.square,
            progressBarColor: Colors.black38,
            thumbColor: Colors.pinkAccent,
            thumbGlowColor: Colors.lightGreen.withOpacity(1),
            thumbGlowRadius: 0.6,
            thumbCanPaintOutsideBar: true,
          );
        });
  }

  void _setShuffle() {
    setState(() {
      _isshuffle = !_isshuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isshuffle ? Colors.purpleAccent : Colors.grey;
  }

  StreamBuilder<PlayerState> _playingButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            _pauseRotationAnim();
            return Container(
              margin: const EdgeInsets.all(8),
              width: 48,
              height: 48,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return MediaButtonController(
                function: () {
                  _audioPlayerManager.player.play();
                },
                icon: Icons.play_arrow,
                color: null,
                size: 48);
          } else if (processingState != ProcessingState.completed) {
            _playRotationAnim();
            return MediaButtonController(
                function: () {
                  _audioPlayerManager.player.pause();
                  _pauseRotationAnim();
                },
                icon: Icons.pause_circle,
                color: null,
                size: 48);
          } else {
            if (processingState == ProcessingState.completed) {
              _stopRotationAnim();
              _resetRotationAnim();
            }
            return MediaButtonController(
                function: () {
                  _curenAnimationPosition = 0.0;
                  _resetRotationAnim();
                  _playRotationAnim();
                },
                icon: Icons.replay,
                color: null,
                size: 48);
          }
        });
  }

  void _setNextSong() {
    if (_isshuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else {
      _selectedItemIndex++;
      if (_selectedItemIndex >= widget.songs.length) {
        if (_loopMode == LoopMode.all) {
          _selectedItemIndex = 0; // Loop to the first song
        } else {
          _selectedItemIndex = widget.songs.length - 1; // Stay on last
        }
      }
    }
    _playSelectedSong();
  }

  void _setPrevSong() {
    if (_isshuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else {
      _selectedItemIndex--;
      if (_selectedItemIndex < 0) {
        if (_loopMode == LoopMode.all) {
          _selectedItemIndex = widget.songs.length - 1; // Loop to the last song
        } else {
          _selectedItemIndex = 0; // Stay on first
        }
      }
    }

    _playSelectedSong();
  }

  void _playSelectedSong(){
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updatSongUrl(nextSong.source);
    setState(() {
      _song = nextSong;
    });
    _resetRotationAnim();
    _audioPlayerManager.player.play();
  }

  void _playRotationAnim() {
    _imageAnimationController.forward(from: _curenAnimationPosition);
    _imageAnimationController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _curenAnimationPosition = _imageAnimationController.value;
  }

  void _stopRotationAnim() {
    _imageAnimationController.stop();
  }

  void _resetRotationAnim() {
    _curenAnimationPosition = 0.0;
    _imageAnimationController.value = _curenAnimationPosition;
  }
}

class MediaButtonController extends StatefulWidget {
  const MediaButtonController(
      {super.key,
      required this.function,
      required this.icon,
      required this.color,
      required this.size});

  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  State<MediaButtonController> createState() => _MediaButtonControllerState();
}

class _MediaButtonControllerState extends State<MediaButtonController> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      // color: widget.color,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}

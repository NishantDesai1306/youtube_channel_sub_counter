import 'package:meta/meta.dart';
import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';

@immutable
class AppState {
  final bool isOnline;
  final List<YoutubeChannel> channels;

  const AppState({
    this.isOnline = false,
    this.channels = const []
  });

  AppState copyWith({
    bool? isOnline,
    List<YoutubeChannel>? channels,
  }) {
    return AppState(
      isOnline: isOnline ?? this.isOnline,
      channels: channels ?? this.channels,
    );
  }

  @override
  int get hashCode =>
      isOnline.hashCode ^
      channels.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AppState &&
              runtimeType == other.runtimeType &&
              isOnline == other.isOnline &&
              channels == other.channels;

  @override
  String toString() {
    return 'AppState{isOnline: $isOnline, channels: $channels}';
  }
}
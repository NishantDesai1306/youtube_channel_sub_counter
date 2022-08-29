import 'package:flutter/widgets.dart';

import 'package:pdp_vs_ts_v3/api/youtube_api.dart';
import 'package:pdp_vs_ts_v3/constants/general.dart';
import 'package:pdp_vs_ts_v3/model/youtube_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/shared_preference_helper.dart';

class YoutubeChannel {
  String _channelId;
  String _channelPicture;
  String _channelName;
  String _channelDescription;
  int _subscriberCount;
  List<YoutubeVideo> _videos = [];

  String _error = '';

  String get channelId => _channelId;
  String get channelPicture => _channelPicture;
  String get channelName => _channelName;
  String get channelDescription => _channelDescription;
  List<YoutubeVideo> get videos => _videos;
  int get subscriberCount => _subscriberCount;

  YoutubeChannel(
      this._channelId,
      this._channelName,
      this._channelDescription,
      this._channelPicture,
      this._subscriberCount,
      this._videos);

  static empty(channelId) {
    return YoutubeChannel(channelId, '', '', '', 0, []);
  }

  static clone(YoutubeChannel channel) {
    return YoutubeChannel(channel.channelId, channel.channelName, channel._channelDescription, channel.channelPicture, channel.subscriberCount, channel.videos);
  }

  static Future<YoutubeChannel> fromChannelId(channelId) async {
    YoutubeChannel youtubeChannel =
    await YoutubeAPI.getYoutubeChannel(channelId);
    return youtubeChannel;
  }

  static Future<YoutubeChannel> fromSharedPreferences(channelId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String channelName = sp.getString(SharedPreferenceHelper.getNameKey(channelId)) ?? '';
    String channelDescription = sp.getString(SharedPreferenceHelper.getDescriptionKey(channelId)) ?? '';
    String channelPicture = sp.getString(SharedPreferenceHelper.getProfilePictureKey(channelId)) ?? '';
    int subscriberCount = sp.getInt(SharedPreferenceHelper.getSubscribersKey(channelId)) ?? 0;

    YoutubeChannel youtubeChannel = YoutubeChannel(channelId, channelName, channelDescription, channelPicture, 0, []);
    youtubeChannel.setSubscriberCount(subscriberCount);
    youtubeChannel.setVideos([]);

    return youtubeChannel;
  }

  void setError(String errorMessage) {
    _error = errorMessage;
  }

  String getError() {
    return _error;
  }

  Future writeToSharedPreferences({bool onlySubscriberCount = false}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    // save data to shared preferences
    if (!onlySubscriberCount) {
      sp.setString(SharedPreferenceHelper.getNameKey(channelId), channelName);
      sp.setString(SharedPreferenceHelper.getProfilePictureKey(channelId), channelPicture);
      sp.setString(SharedPreferenceHelper.getDescriptionKey(channelId), channelDescription);
    }

    sp.setInt(SharedPreferenceHelper.getSubscribersKey(channelId), subscriberCount);
  }

  void setVideos(List<YoutubeVideo> videos) {
    _videos = videos;
  }

  void setSubscriberCount(int subscriberCount) {
    _subscriberCount = subscriberCount;
    writeToSharedPreferences(onlySubscriberCount: true);
  }

  @override
  String toString() {
    return '$_channelName - ${_subscriberCount.toString()}';
  }
}

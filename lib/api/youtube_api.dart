import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pdp_vs_ts_v3/constants/general.dart';

import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/model/youtube_video.dart';
import 'package:pdp_vs_ts_v3/utils/index.dart';

class YoutubeAPI {
  static Future<YoutubeChannel> getYoutubeChannel(channelId) async {
    bool result = await InternetConnectionChecker().hasConnection;

    // if internet connection is not available then load info from shared preferences
    if (result == false) {
      YoutubeChannel youtubeChannel =
      await YoutubeChannel.fromSharedPreferences(channelId);
      return youtubeChannel;
    }

    List<String> fields = [
      'snippet',
    ];
    String requiredFields = fields.join("%2C");
    Map<String, String> headers = {"Accept": "application/json"};

    var response;
    String responseBody = '';

    try {
      Uri uri = getYoutubeUri('channels', {
        'id': channelId,
        'part': requiredFields,
        'key': YOUTUBE_API_KEY,
      });
      response = await http.get(uri, headers: headers);

      responseBody = response.body;
    } catch (e) {
      print(e.toString());
    }

    if (response != null && response.statusCode != 200) {
      String errorMessage = "got invalid response $responseBody";
      YoutubeChannel emptyChannel = YoutubeChannel.empty(channelId);

      emptyChannel.setError(errorMessage);

      return emptyChannel;
    }

    var responseJSON = json.decode(responseBody);
    var channelDetails = responseJSON['items'][0];

    if (channelDetails == null) {
      String errorMessage =
          'Something went wrong. \nresponse Code : ${response.statusCode}';
      YoutubeChannel emptyChannel = YoutubeChannel.empty(channelId);

      emptyChannel.setError(errorMessage);

      return emptyChannel;
    }

    var snippet = responseJSON['items'][0]['snippet'];

    String channelName = snippet['title'];
    String channelPicture = snippet['thumbnails']['high']['url'];

    int subscriberCount = await getSubscriberCount(channelId);
    List<YoutubeVideo> videos = await getTopVideos(channelId);
    YoutubeChannel youtubeChannel = YoutubeChannel(channelId, channelName, channelPicture, 0, []);

    youtubeChannel.setSubscriberCount(subscriberCount);
    youtubeChannel.setVideos(videos);
    youtubeChannel.writeToSharedPreferences();

    return youtubeChannel;
  }

  static Future<int> getSubscriberCount(channelId) async {
    bool result = await InternetConnectionChecker().hasConnection;

    // if internet connection is not available then load info from shared preferences
    if (result == false) {
      YoutubeChannel youtubeChannel =
      await YoutubeChannel.fromSharedPreferences(channelId);
      return youtubeChannel.subscriberCount;
    }

    int subscriberCount = 0;
    List<String> fields = ['statistics'];
    String requiredFields = fields.join("%2C");
    Map<String, String> headers = {"Accept": "application/json"};

    var response;

    try {
      Uri uri = getYoutubeUri('channels', {
        'id': channelId,
        'part': requiredFields,
        'key': YOUTUBE_API_KEY,
      });
      response = await http.get(uri, headers: headers);
    } catch (e) {
      print(e.toString());
    }

    if (response != null && response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      var channelDetails = responseJSON['items'][0];

      if (channelDetails != null) {
        var statistics = responseJSON['items'][0]['statistics'];

        subscriberCount = int.parse(statistics['subscriberCount']);
      }

      print("response body: $responseBody");
    }

    return subscriberCount;
  }

  static Future<List<YoutubeVideo>> getTopVideos(channelId) async {
    bool result = await InternetConnectionChecker().hasConnection;

    // if internet connection is not available then load info from shared preferences
    if (result == false) {
      YoutubeChannel youtubeChannel =
      await YoutubeChannel.fromSharedPreferences(channelId);
      return youtubeChannel.videos;
    }

    Map<String, String> headers = {"Accept": "application/json"};

    List<YoutubeVideo> videos = [];

    var response;
    Uri uri = getYoutubeUri('search', {
      'part': 'snippet',
      'channelId': channelId,
      'maxResults': VIDEO_LIST_SIZE.toString(),
      'order': 'viewCount',
      'key': YOUTUBE_API_KEY,
      'type': 'video',
    });

    try {
      response = await http.get(uri, headers: headers);
    } catch (e) {
      print(e.toString());
    }

    if (response != null && response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      List videoDetails = responseJSON['items'];

      for (var videoDetail in videoDetails) {
        String videoId = videoDetail['id']['videoId'];
        var snippet = videoDetail['snippet'];
        String videoTitle = snippet['title'];
        String videoDescription = snippet['description'];
        String videoThumbnailUrl = snippet['thumbnails']['high']['url'];
        YoutubeVideo youtubeVideo = YoutubeVideo(videoId, videoTitle, videoThumbnailUrl, videoDescription);

        videos.add(youtubeVideo);
      }
    }

    return videos;
  }
}

import 'package:pdp_vs_ts_v3/redux/models/app_state_model.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/api/youtube_api.dart';

class UpsertChannelAction {
  final YoutubeChannel channel;

  UpsertChannelAction(this.channel);

  @override
  String toString() {
    return 'UpsertChannelAction{channel: ${channel.channelId}}';
  }
}

class DeleteChannelAction {
  final String channelId;

  DeleteChannelAction(this.channelId);

  @override
  String toString() {
    return 'DeleteChannelAction{channelId: $channelId';
  }
}

ThunkAction<AppState> updateSubscriberCount(YoutubeChannel channel) {
  return (Store<AppState> store) async {
    int updatedSubscriberCount = await YoutubeAPI.getSubscriberCount(channel.channelId);
    YoutubeChannel updatedChannel = YoutubeChannel.clone(channel);

    updatedChannel.setSubscriberCount(updatedSubscriberCount);

    store.dispatch(UpsertChannelAction(updatedChannel));
  };
}


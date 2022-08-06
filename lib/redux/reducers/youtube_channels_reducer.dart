import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/redux/actions/youtube_channel_actions.dart';
import 'package:redux/redux.dart';

List <YoutubeChannel> deleteChannelReducer(List<YoutubeChannel> state, DeleteChannelAction action) {
  int index = state.indexWhere((channel) => channel.channelId == action.channelId);
  return List.unmodifiable(List.from(state)..removeAt(index));
}

List <YoutubeChannel> upsertChannelReducer(List<YoutubeChannel> state, UpsertChannelAction action) {
  int index = state.indexWhere((channel) => channel.channelId == action.channel.channelId);

  if (index == -1) {
    // if channel with same channel id does not exists then insert it in the list
    return [...state, action.channel];
  }
  else {
    // if channel wth same channel id exists then replace it in the list
    return List.unmodifiable(List.from(state)..removeAt(index)..insert(index, action.channel));
  }
}

final Reducer <List<YoutubeChannel>> channelsReducer = combineReducers<List<YoutubeChannel>>([
  TypedReducer<List<YoutubeChannel>, UpsertChannelAction>(upsertChannelReducer),
  TypedReducer<List<YoutubeChannel>, DeleteChannelAction>(deleteChannelReducer),
]);
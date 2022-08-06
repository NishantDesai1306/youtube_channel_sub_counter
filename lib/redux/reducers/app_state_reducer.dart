import 'package:pdp_vs_ts_v3/redux/models/app_state_model.dart';
import 'package:pdp_vs_ts_v3/redux/reducers/internet_status_reducer.dart';
import 'package:pdp_vs_ts_v3/redux/reducers/youtube_channels_reducer.dart';

AppState appReducer(AppState state, action) {
  return AppState(
    isOnline: internetStatusReducer(state.isOnline, action),
    channels: channelsReducer(state.channels, action),
  );
}
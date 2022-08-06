import 'package:pdp_vs_ts_v3/redux/actions/internet_status_actions.dart';
import 'package:redux/redux.dart';

bool setInternetStatusReducer(bool state, SetInternetStatusAction action) {
  return action.status;
}

final Reducer <bool> internetStatusReducer = combineReducers<bool>([
  TypedReducer<bool, SetInternetStatusAction>(setInternetStatusReducer),
]);
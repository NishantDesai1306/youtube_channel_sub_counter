import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:pdp_vs_ts_v3/pages/set_channels.dart';
import 'package:pdp_vs_ts_v3/utils/index.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pdp_vs_ts_v3/redux/actions/internet_status_actions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pdp_vs_ts_v3/redux/models/app_state_model.dart';
import 'package:pdp_vs_ts_v3/redux/reducers/app_state_reducer.dart';
import 'package:pdp_vs_ts_v3/constants/strings.dart';
import 'package:pdp_vs_ts_v3/constants/theme.dart';
import 'package:pdp_vs_ts_v3/pages/about_me.dart';
import 'package:pdp_vs_ts_v3/pages/app_explanation.dart';
import 'package:pdp_vs_ts_v3/pages/main_page.dart';
import 'package:pdp_vs_ts_v3/pages/splash.dart';

final store = Store<AppState>(
  appReducer,
  initialState: const AppState(isOnline: false, channels: []),
  middleware: [
    thunkMiddleware,
    // LoggingMiddleware.printer(),
  ]
);

void main() {
  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  final Store<AppState> store;

  const MyApp({Key? key, required this.store}): super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> subscription;

  MyAppState() {
    setInternetStatus();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      setInternetStatus();
    });

    requestInternetPermission();
  }

  requestInternetPermission() async {
    bool hasPermission = await Permission.storage.request().isGranted;
  }

  setInternetStatus () async {
    bool isConnectedToInternet = await isOnline();
    widget.store.dispatch(SetInternetStatusAction(isConnectedToInternet));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: widget.store,
        child: DynamicTheme(
            themeCollection: themeCollection,
            defaultThemeId: AppThemes.light,
            builder: (context, theme) {
              return
                MaterialApp(
                    title: APP_NAME,
                    theme: theme,
                    home: const SplashPage(),
                    routes: <String, WidgetBuilder>{
                      SplashPage.route: (BuildContext context) => const SplashPage(),
                      MainPage.route: (BuildContext context) => const MainPage(),
                      SetChannels.route: (BuildContext context) => const SetChannels(),
                      AboutMePage.route: (BuildContext context) => const AboutMePage(),
                      AppExplanation.route: (BuildContext context) =>
                      const AppExplanation(),
                    });
            })
    );
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }
}

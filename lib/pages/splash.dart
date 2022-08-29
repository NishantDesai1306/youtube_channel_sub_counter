import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdp_vs_ts_v3/pages/set_channels.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';
import 'package:pdp_vs_ts_v3/pages/app_explanation.dart';
import 'package:pdp_vs_ts_v3/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  static const String route = '/splash';

  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  SplashPageState() {
    goToNextPage();
  }

  goToNextPage() async {
    SharedPreferences sp = await _prefs;
    bool isAppExplained = sp.getBool(SharedPreferenceHelper.getAppExplanationKey()) ?? false;
    List<String>? channels = sp.getStringList(SharedPreferenceHelper.getSelectedChannelIdsKey());
    String nextPageRoute = '';

    if (isAppExplained) {
      if (channels == null) {
        nextPageRoute = SetChannels.route;
      }
      else {
        nextPageRoute = MainPage.route;
      }
    }
    else {
      nextPageRoute = AppExplanation.route;
    }

    Navigator.of(context).pushReplacementNamed(nextPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

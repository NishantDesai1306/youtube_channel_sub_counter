import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:pdp_vs_ts_v3/constants/general.dart';

import 'native.dart'
if (dart.library.html) 'web.dart' as platform_specific_utils;

Uri getYoutubeUri(String path, Map<String, String> queryParameters) {
  List<String> urlSplits = YOUTUBE_API_URL.split("://");
  String scheme = urlSplits.elementAt(0);
  String urlString = urlSplits.elementAt(1);
  List<String> urlFragments = urlString.split("/");

  String domain = urlFragments.elementAt(0);
  urlFragments.removeAt(0);

  if (path.isNotEmpty) {
    urlFragments.add(path);
  }

  Uri uri = Uri(
    scheme: scheme,
    host: domain,
    path: urlFragments.join("/"),
    queryParameters: queryParameters,
  );

  return uri;
}

Future<bool> isOnline () async {
  bool isOnline = false;

  if (kIsWeb) {
    isOnline = true;
  }
  else {
    InternetConnectionChecker internetChecker = InternetConnectionChecker();
    isOnline = await internetChecker.hasConnection;
  }

  return isOnline;
}

double getLayoutWidth (context) {
  double deviceWidth = MediaQuery.of(context).size.width;
  double width = deviceWidth;

  if (deviceWidth > WEB_BREAKPOINT_WIDTH) {
    width = WEB_BREAKPOINT_WIDTH;
  }

  return width;
}

Future<String?> downloadFile (bytes, filename) async {
  return platform_specific_utils.downloadFile(bytes, filename);
}
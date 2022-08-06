import 'package:pdp_vs_ts_v3/constants/general.dart';

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
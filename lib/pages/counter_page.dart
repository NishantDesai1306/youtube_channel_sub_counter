import "dart:async";
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "dart:typed_data";
import "dart:ui" as ui;
import 'dart:io' as io;

import "package:flutter/rendering.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pdp_vs_ts_v3/pages/set_channels.dart';
import 'package:pdp_vs_ts_v3/utils/index.dart';
import 'package:share_plus/share_plus.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:permission_handler/permission_handler.dart';

import 'package:pdp_vs_ts_v3/constants/general.dart';
import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';
import 'package:pdp_vs_ts_v3/main.dart';
import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/redux/actions/youtube_channel_actions.dart';
import 'package:pdp_vs_ts_v3/redux/models/app_state_model.dart';
import 'package:pdp_vs_ts_v3/widgets/counter_page/channel_ui.dart';
import 'package:pdp_vs_ts_v3/widgets/counter_page/confirm_screenshot_dialog.dart';
import 'package:pdp_vs_ts_v3/widgets/counter_page/full_screen_loader.dart';
import 'package:pdp_vs_ts_v3/widgets/counter_page/subscriber_difference.dart';

class CounterPage extends StatefulWidget {
  final bool isSettingsOpen;

  const CounterPage({Key? key, required this.isSettingsOpen}) : super(key: key);

  @override
  CounterPageState createState() => CounterPageState();
}

class CounterPageState extends State<CounterPage> {
  static GlobalKey widgetContainerKey = GlobalKey();

  late StreamSubscription<AppState> subscription;
  late StreamSubscription<bool> isOnlineReduxStoreSubscription;

  StreamController<bool> isOnlineReduxStore = StreamController();

  bool isConnectedToInternet = store.state.isOnline;
  bool shouldRenderNotifier = false;

  final textStyle = const TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, fontFamily: "Roboto");
  final isMobileApp = !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);

  CounterPageState() {
    Timer.periodic(const Duration(seconds: 100), reloadSubscriberCount);

    // listen to changes in entire state
    subscription = store.onChange.listen((appState) async {
      bool currentStatus = appState.isOnline;
      bool lastStatus = isConnectedToInternet;
      bool hasValueChanged = lastStatus != currentStatus;

      if (hasValueChanged) {
        isOnlineReduxStore.add(currentStatus);
      }
    });

    // listen to changes in only appState.isOnline of redux store;
    isOnlineReduxStoreSubscription = isOnlineReduxStore.stream.listen((isOnline) {
      setState(() {
        shouldRenderNotifier = true;
        isConnectedToInternet = isOnline;
      });
    });

    loadChannels();
  }

  void loadChannels() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String>? channels = sp.getStringList(SharedPreferenceHelper.getSelectedChannelIdsKey());

    if (channels == null) {
      print('channels not found, taking user to set channels screen');
      Navigator.of(context).pushReplacementNamed(SetChannels.route);
    }

    YoutubeChannel channel1 = await YoutubeChannel.fromChannelId(channels?.elementAt(0));
    YoutubeChannel channel2 = await YoutubeChannel.fromChannelId(channels?.elementAt(1));

    store.dispatch(UpsertChannelAction(channel1));
    store.dispatch(UpsertChannelAction(channel2));
  }

  void reloadSubscriberCount(Timer timer) {
    shouldRenderNotifier = false;

    for (YoutubeChannel channel in store.state.channels) {
      store.dispatch(updateSubscriberCount(channel));
    }
  }

  Future<bool> askStoragePermissionIfRequired() async {
    // for web app we don't need to ask for permission
    if (kIsWeb) return true;

    bool hasPermission = await Permission.storage.request().isGranted;

    if (!hasPermission) {
      // if user has not given permission then show error message
      showSnackBar(message: 'Please authorize this app to write on storage');
      return false;
    }

    return true;
  }

  Future<bool?> confirmAboutScreenshot() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String key = SharedPreferenceHelper.getLongPressScreenshotKey();
    bool? dontShowAgainValue = sp.getBool(key);

    // if user has checked don't show again last time then send the value that was selected last time
    if (dontShowAgainValue != null) {
      return dontShowAgainValue;
    }

    bool? returnValue = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) =>
            ConfirmScreenshotDialog(dontShowAgainPreferenceKey: key));

    if (false == returnValue) {
      showSnackBar(message: 'Screenshot cancelled');
    }

    return returnValue;
  }

  Future<bool> checkPermissions() async {
    bool? isSafeToProceed = false;

    isSafeToProceed = await confirmAboutScreenshot();

    if (isSafeToProceed == false || isSafeToProceed == null) {
      return false;
    }

    isSafeToProceed = await askStoragePermissionIfRequired();

    if (!isSafeToProceed) {
      return false;
    }

    return true;
  }

  Future<String?> storeScreenShot() async {
    // generate data for screenshot
    final RenderRepaintBoundary boundary = widgetContainerKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    String timeStamp = DateTime.now().toString().substring(0, 18);
    String filename = "screenshot $timeStamp.png";

    // write screenshot image
    if (pngBytes != null) {
      return downloadFile(pngBytes, filename);
    }

    return null;
  }

  takeScreenShot() async {
    try {
      if (widget.isSettingsOpen) {
        return;
      }

      bool isSafeToProceed = await checkPermissions();

      if (!isSafeToProceed) {
        return;
      }

      String? savedImagePath = await storeScreenShot();

      if (savedImagePath != null) {
        final box = context.findRenderObject() as RenderBox?;

        // notify user and open share popup
        showSnackBar(message: "Screenshot saved successfully");

        if (savedImagePath.isNotEmpty) {
          Share.shareFiles([savedImagePath],
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
        }
      }
    }
    catch (e) {
      print(e.toString());
    }
  }

  showSnackBar({required String message, int seconds = 3}) {
    SnackBar snackBar =
        SnackBar(content: Text(message), duration: Duration(seconds: seconds));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    if (shouldRenderNotifier) {
      Timer.run(() {
        String message = isConnectedToInternet
            ? "You're connected, please wait a few seconds for latest subscriber count"
            : "You're right now seeing last saved data, to check latest subscriber count connect this device to internet";

        showSnackBar(message: message);
      });
    }
    return GestureDetector(
      onLongPress: takeScreenShot,
      child: RepaintBoundary(
        key: widgetContainerKey,
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: StoreConnector<AppState, List<YoutubeChannel>>(
            converter: (store) => store.state.channels,
            builder: (context, channels) {
              if (channels.isEmpty) {
                return FullscreenLoader(
                    messageWidget: Text("Loading data...", style: textStyle)
                );
              }

              print('Channels: $channels');

              YoutubeChannel channel1 = channels.elementAt(0);
              YoutubeChannel channel2 = channels.elementAt(1);

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ChannelUI(youtubeChannel: channel1)
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          alignment: Alignment.center,
                          child: DifferenceWidget(
                            channel1: channel1,
                            channel2: channel2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ChannelUI(youtubeChannel: channel2)
                          ],
                        ),
                        // show download button only in web app as long press is not a conventional interaction patter for webapps
                        isMobileApp ? Container() : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: FloatingActionButton(
                                tooltip: "Download Screenshot",
                                onPressed: takeScreenShot,
                                child: const Icon(Icons.download),
                              ),
                            )
                          ],
                        )
                      ]
                  ),
                ),
              );
            },
          )
        )
      ),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    isOnlineReduxStoreSubscription.cancel();
    super.dispose();
  }
}

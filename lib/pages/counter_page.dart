import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "dart:typed_data";
import "dart:ui" as ui;
import "package:flutter/rendering.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pdp_vs_ts_v3/main.dart';
import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/redux/actions/youtube_channel_actions.dart';
import 'package:pdp_vs_ts_v3/redux/models/app_state_model.dart';
import 'package:pdp_vs_ts_v3/widgets/counter.dart';
import 'package:redux/redux.dart';
import 'package:share_plus/share_plus.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:permission_handler/permission_handler.dart';

import 'package:pdp_vs_ts_v3/constants/general.dart';
import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';
import 'package:pdp_vs_ts_v3/pages/youtube_channel_details_page.dart';

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

  CounterPageState() {
    Timer.periodic(const Duration(seconds: 5), reloadSubscriberCount);

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
    YoutubeChannel tSeriesChannel = await YoutubeChannel.fromChannelId(TSERIES_CHANNEL_ID);
    YoutubeChannel pewDiePieChannel = await YoutubeChannel.fromChannelId(PEW_DIE_PIE_CHANNEL_ID);

    store.dispatch(UpsertChannelAction(tSeriesChannel));
    store.dispatch(UpsertChannelAction(pewDiePieChannel));
  }

  void reloadSubscriberCount(Timer timer) {
    shouldRenderNotifier = false;

    for (YoutubeChannel channel in store.state.channels) {
      store.dispatch(updateSubscriberCount(channel));
    }
  }

  Future<bool> askStoragePermissionIfRequired() async {
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

  Future<File?> storeScreenShot() async {
    // generate data for screenshot
    final RenderRepaintBoundary boundary = widgetContainerKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();

    // write screenshot image
    if (pngBytes != null) {
      String timeStamp = DateTime.now().toString().substring(0, 18);
      String screenshotPath = "$BASE_FOLDER_PATH/screenshot $timeStamp.png";
      File screenshotImage = File(screenshotPath);
      await screenshotImage.writeAsBytes(pngBytes);
      return screenshotImage;
    }

    return null;
  }

  takeScreenShot() async {
    if (widget.isSettingsOpen) {
      return;
    }

    bool isSafeToProceed = await checkPermissions();

    if (!isSafeToProceed) {
      return;
    }

    // if directory does not exists then create it
    Directory dir = Directory(BASE_FOLDER_PATH);

    if (!dir.existsSync()) {
      dir.createSync();
    }

    File? savedImage = await storeScreenShot();

    if (savedImage != null) {
      final box = context.findRenderObject() as RenderBox?;

      // notify user and open share popup
      showSnackBar(message: "Screenshot saved successfully");
      Share.shareFiles([savedImage.path],
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
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

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ChannelUI(youtubeChannel: channel1)
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: DifferenceWidget(
                      channel1: channel1,
                      channel2: channel2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ChannelUI(youtubeChannel: channel2)
                    ],
                  ),
                ]
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

class ChannelUI extends StatelessWidget {
  final YoutubeChannel youtubeChannel;
  final textStyle = const TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, fontFamily: "Roboto");
  final defaultMargin = const EdgeInsets.fromLTRB(0, 10, 0, 0);

  const ChannelUI({Key? key, required this.youtubeChannel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String channelId = youtubeChannel.channelId;
    String channelName = youtubeChannel.channelName;
    int subscriberCount = youtubeChannel.subscriberCount;

    ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    double imageDimension = width * 0.4;
    double borderWidth = 5;

    if (channelName == '') {
      return Container();
    }

    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: defaultMargin,
              child: Container(
                alignment: Alignment.center,
                child: Hero(
                  tag: "${channelId}_picture",
                  child: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(
                              imageDimension / 2 + borderWidth),
                          border: Border.all(
                              color: theme.primaryColor, width: borderWidth)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(imageDimension / 2),
                        child: YoutubeChannel.getProfilePicture(
                            channelId, imageDimension),
                      ),
                    ),
                    onDoubleTap: () {},
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YoutubeChannelDetailsPage(
                                  youtubeChannel: youtubeChannel,
                                  description: youtubeChannel.channelId ==
                                          TSERIES_CHANNEL_ID
                                      ? T_SERIES_DESCRIPTION
                                      : PEW_DIE_PIE_DECSRIPTION)));
                    },
                  ),
                ),
              ),
            ),
            Container(
              margin: defaultMargin,
              child: Text(
                channelName,
                style: textStyle,
              ),
            ),
            Container(
              margin: defaultMargin,
              child: CounterWidget(value: subscriberCount, textStyle: textStyle),
            )
          ],
        ));
  }
}

class DifferenceWidget extends StatelessWidget {
  final YoutubeChannel channel1, channel2;

  const DifferenceWidget(
      {Key? key, required this.channel1, required this.channel2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (channel1.subscriberCount == 0 ||
        channel2.subscriberCount == 0) {
      return Container();
    }

    int difference =
        channel2.subscriberCount - channel1.subscriberCount;
    String differenceText = "";

    if (difference == 0) {
      differenceText =
          "${channel1.channelName} and ${channel2.channelName} has same number of subscribers";

      return Text(
        differenceText,
        textAlign: TextAlign.center,
      );
    } else if (difference > 0) {
      differenceText = "${channel2.channelName} is ahead by";
    } else if (difference < 0) {
      differenceText = "${channel1.channelName} is ahead by";
    }

    TextStyle textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18.0,
    );

    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(5.0)),
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Wrap(alignment: WrapAlignment.center, children: <Widget>[
          Text("$differenceText ${difference.abs()} subscribers.", style: textStyle),
        ]));
  }
}

class FullscreenLoader extends StatelessWidget {
  final Widget messageWidget;

  const FullscreenLoader({Key? key, required this.messageWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            messageWidget
          ],
        )
      ],
    );
  }
}

class ConfirmScreenshotDialog extends StatefulWidget {
  final String dontShowAgainPreferenceKey;

  const ConfirmScreenshotDialog(
      {Key? key, required this.dontShowAgainPreferenceKey})
      : super(key: key);

  @override
  State<ConfirmScreenshotDialog> createState() =>
      ConfirmScreenshotDialogState();
}

class ConfirmScreenshotDialogState extends State<ConfirmScreenshotDialog> {
  bool dontShowAgain = false;

  ConfirmScreenshotDialogState();

  handleDontShowAgainChange(bool isChecked) {
    setState(() {
      dontShowAgain = isChecked;
    });
  }

  setPreferenceAndReturn(bool isChecked) async {
    if (dontShowAgain) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setBool(widget.dontShowAgainPreferenceKey, isChecked);
    }

    return Navigator.of(context).pop(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle textStyle = TextStyle(color: theme.textTheme.bodyText1?.color);

    return SimpleDialog(
      title: Text("Press and Hold Screenshot", style: textStyle),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              Text(
                  "Do you want to share a screenshot of current subscriber count ?",
                  style: textStyle),
              Row(
                children: <Widget>[
                  Switch(
                    activeColor: theme.primaryColor,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    onChanged: handleDontShowAgainChange,
                    value: dontShowAgain,
                  ),
                  Text("Don't ask me again", style: textStyle)
                ],
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton(
              child: Text("No", style: textStyle),
              onPressed: () {
                setPreferenceAndReturn(false);
              },
            ),
            TextButton(
              child: Text("Yes", style: textStyle),
              onPressed: () {
                setPreferenceAndReturn(true);
              },
            )
          ],
        )
      ],
    );
  }
}

import "dart:async";
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import "package:shared_preferences/shared_preferences.dart";

import 'package:pdp_vs_ts_v3/main.dart';
import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/api/youtube_api.dart';
import 'package:pdp_vs_ts_v3/redux/models/app_state_model.dart';
import 'package:pdp_vs_ts_v3/widgets/channel_preview.dart';
import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';

import '../constants/strings.dart';
import 'main_page.dart';

class SetChannels extends StatefulWidget {
  static const String route = '/set_channels';

  const SetChannels({Key? key}) : super(key: key);

  @override
  SetChannelsState createState() => SetChannelsState();
}

class SetChannelsState extends State<SetChannels> {
  YoutubeChannel channel1 = YoutubeChannel("", "Channel 1", "", "", 0, []);
  YoutubeChannel channel2 = YoutubeChannel("", "Channel 2", "", "", 0, []);

  late StreamSubscription<AppState> subscription;
  late StreamSubscription<bool> isOnlineReduxStoreSubscription;

  StreamController<bool> isOnlineReduxStore = StreamController();

  bool isConnectedToInternet = store.state.isOnline;
  bool shouldRenderNotifier = false;

  final textStyle = const TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, fontFamily: "Roboto");
  final isMobileApp = !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);

  SetChannelsState() {
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
  }

  showSnackBar({required String message, int seconds = 3}) {
    SnackBar snackBar =
    SnackBar(content: Text(message), duration: Duration(seconds: seconds));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void saveChannels() async {
    List<String> channelIds = [
      channel1.channelId,
      channel2.channelId,
    ];
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setStringList(SharedPreferenceHelper.getSelectedChannelIdsKey(), channelIds);

    Navigator.of(context).pushReplacementNamed(MainPage.route);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (shouldRenderNotifier) {
      Timer.run(() {
        String message = isConnectedToInternet
            ? "You're connected, please wait a few seconds for latest subscriber count"
            : "You're right now seeing last saved data, to check latest subscriber count connect this device to internet";

        showSnackBar(message: message);
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: theme.iconTheme,
        centerTitle: true,
        title: Text(APP_NAME),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
          alignment: Alignment.center,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ChannelPreview(
                          youtubeChannel: channel1,
                          onClick: () async {
                            final channel = await showSearch(context: context, delegate: YoutubeChannelSearchDelegate());

                            if (channel != null) {
                              setState(() {
                                channel1 = channel;
                              });
                            }
                          },
                          shouldRenderEmpty: true,
                        )
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ChannelPreview(
                          youtubeChannel: channel2,
                          onClick: () async {
                            final channel = await showSearch(context: context, delegate: YoutubeChannelSearchDelegate());

                            if (channel != null) {
                              setState(() {
                                channel2 = channel;
                              });
                            }
                          },
                          shouldRenderEmpty: true,
                        )
                      ],
                    ),

                    const SizedBox(height: 50),
                    channel1.channelId.isNotEmpty && channel2.channelId.isNotEmpty
                      ? ElevatedButton(
                        onPressed: saveChannels,
                        child: const Text('Save'),
                      ) : Container(),
                  ]
              ),
            ),
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

class YoutubeChannelSearchDelegate extends SearchDelegate<YoutubeChannel?> {
  bool isLoading = false;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            showResults(context);
          },
          icon: const Icon(Icons.search)
      ),
      IconButton(
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            }
            else {
              query = "";
            }
          },
          icon: const Icon(Icons.close)
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return FutureBuilder<List<YoutubeChannel>>(
      future: YoutubeAPI.searchYoutubeChannels(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.warning),
                  SizedBox(width: 15),
                  Text("Something went wrong, while loading channels."),
                ],
              ),
            );
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              const textStyle = TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: "Roboto");
              YoutubeChannel? channel = snapshot.data?.elementAt(index);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    close(context, channel);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: TransitionToImage(
                          image: AdvancedNetworkImage(channel != null ? channel.channelPicture : ""),
                          loadingWidget: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                          ),
                          fit: BoxFit.cover,
                          width: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(channel != null ? channel.channelName : "", style: textStyle,),
                    ],
                  ),
                ),
              );
            },
            itemCount: snapshot.data != null ? snapshot.data?.length : 0,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

}
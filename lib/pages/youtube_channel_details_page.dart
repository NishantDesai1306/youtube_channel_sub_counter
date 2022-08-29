
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdp_vs_ts_v3/utils/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';

import '../model/youtube_channel.dart';

class YoutubeChannelDetailsPage extends StatefulWidget {
  final YoutubeChannel youtubeChannel;

  const YoutubeChannelDetailsPage({Key? key, required this.youtubeChannel}): super(key: key);

  @override
  State<StatefulWidget> createState() => _YoutubeChannelDetailsPage();
}

class _YoutubeChannelDetailsPage extends State<YoutubeChannelDetailsPage> {
  final NumberFormat nf = NumberFormat.simpleCurrency(decimalDigits: 0, name: 'JPY', locale: 'en_US');
  final TextStyle textStyle = const TextStyle(fontSize: 18);
  final TextStyle titleTextStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  final EdgeInsets basicSpacing = const EdgeInsets.only(top: 10, bottom: 10);

  List<Widget> getSliverWidgets() {
    YoutubeChannel youtubeChannel = widget.youtubeChannel;

    String formattedSubscriberCount = nf.format(youtubeChannel.subscriberCount).substring(1);
    ThemeData theme = Theme.of(context);
    double width = getLayoutWidth(context);
    double sliverExpandedHeight = width - Get.statusBarHeight;
    double imageDimension = width * 0.4;

    Widget sliverBar = SliverAppBar(
      expandedHeight: sliverExpandedHeight,
      floating: false,
      pinned: true,
      primary: true,
      backgroundColor: theme.primaryColor,
      iconTheme: theme.iconTheme,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Chip(
          backgroundColor: theme.primaryColor,
          label: Text(
              youtubeChannel.channelName,
              style: theme.appBarTheme.toolbarTextStyle
          ),
        ),
        background: Hero(
          tag: '${youtubeChannel.channelId}_picture',
          child: TransitionToImage(
            image: AdvancedNetworkImage(youtubeChannel.channelPicture),
            loadingWidget: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
            fit: BoxFit.cover,
            width: imageDimension,
          ),
        ),
      ),
      toolbarTextStyle: theme.textTheme.bodyText2,
      titleTextStyle: theme.textTheme.headline6,
    );
    Widget sliverList = SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          color: theme.backgroundColor,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              kIsWeb ? Hero(
                tag: '${youtubeChannel.channelId}_picture',
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(
                          imageDimension / 2)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(imageDimension / 2),
                    child: TransitionToImage(
                      image: AdvancedNetworkImage(youtubeChannel.channelPicture),
                      loadingWidget: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      ),
                      fit: BoxFit.cover,
                      width: imageDimension,
                    ),
                  ),
                ),
              ) : Container(),
              Container(
                margin: basicSpacing,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Description:', style: titleTextStyle),
                      Text(youtubeChannel.channelDescription, style: textStyle),
                    ]),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: basicSpacing,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Subscriber Count:', style: titleTextStyle),
                      Text(formattedSubscriberCount, style: textStyle),
                    ]),
              ),
              Container(
                margin: basicSpacing,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Top Videos:', style: titleTextStyle),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 100,
                        child: TopVideoList(youtubeChannel: youtubeChannel),
                      ),
                    ]),
              ),
            ],
          ),
        );
      }, childCount: 1),
    );

    return kIsWeb ? [sliverList] : [sliverBar, sliverList];
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    YoutubeChannel youtubeChannel = widget.youtubeChannel;
    List<Widget> sliverWidgets = getSliverWidgets();

    return Scaffold(
      appBar: kIsWeb ? AppBar(
        centerTitle: true,
        iconTheme: theme.iconTheme,
        title: Text(
            youtubeChannel.channelName,
            style: theme.appBarTheme.titleTextStyle
        ),
      ) : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Uri url = Uri(
            scheme: 'https',
            host: 'www.youtube.com',
            path: 'channel/${youtubeChannel.channelId}',
            queryParameters: {
              'sub_confirmation': '1',
            }
          );

          launchUrl(url);
        },
        tooltip: "Open ${youtubeChannel.channelName} in Youtube",
        child: Image.asset('assets/images/youtube_icon.png'),
      ),
      body: CustomScrollView(
        slivers: sliverWidgets
      ),
    );
  }
}

class TopVideoList extends StatelessWidget {
  final YoutubeChannel youtubeChannel;

  const TopVideoList({Key? key, required this.youtubeChannel}): super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return ListView(
        scrollDirection: Axis.horizontal,
        children: youtubeChannel.videos.map((video) {
          return Container(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Opacity(
                      opacity: 0.75,
                      child: TransitionToImage(
                        image: AdvancedNetworkImage(video.thumbnail),
                        loadingWidget: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        ),
                        fit: BoxFit.cover,
                        width: 180,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.play_circle_filled,
                    color: Colors.black,
                    size: 35,
                  )
                ],
              ),
              onTap: () {
                Uri url = Uri(
                  scheme: 'https',
                  host: 'www.youtube.com',
                  path: 'watch',
                  queryParameters: {
                    'v': video.id,
                  }
                );
                launchUrl(url);
              },
            ),
          );
        }).toList());
  }
}

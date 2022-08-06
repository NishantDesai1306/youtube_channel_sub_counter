
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/youtube_channel.dart';

const PEW_DIE_PIE_DECSRIPTION =
    "Felix Arvid Ulf Kjellberg known online as PewDiePie, is a Swedish YouTuber, comedian and video game commentator, formerly best known for his Let's Play commentaries and now mostly known for his comedic formatted shows. \n\n On 15 August 2013, PewDiePie became the most-subscribed user on YouTube, being briefly surpassed in late 2013 by YouTube Spotlight. After regaining the top position on 23 December 2013 the channel has now amassed over 79 million subscribers as of December 2018. From 29 December 2014 to 14 February 2017, PewDiePie's channel held the distinction of being the most-viewed YouTube channel, and as of November 2018, the channel has received over 19 billion video views.";
const T_SERIES_DESCRIPTION =
    "T-Series is an Indian music record label and film production company founded by Gulshan Kumar in 1983. It is primarily known for Bollywood music soundtracks and Indi-pop music. As of 2017, T-Series is one of the largest Indian music record labels, along with Zee Music and Sony Music India.\n\nThe T-Series YouTube channel, run by a small team of 13 people, primarily shows music videos and occasionally film trailers. It is the most-viewed YouTube channel, with over 56 billion views as of 19 December 2018. With over 77 million subscribers as of 30 December 2018, it also ranks as the second most-subscribed channel behind PewDiePie. In addition, T-Series has a multi-channel network, with 29 channels that have more than 100 million YouTube subscribers as of November 2018 and 61.5 billion views as of August 2018.";

class YoutubeChannelDetailsPage extends StatefulWidget {
  final String description;
  final YoutubeChannel youtubeChannel;

  const YoutubeChannelDetailsPage({Key? key, required this.youtubeChannel, required this.description}): super(key: key);

  @override
  State<StatefulWidget> createState() => _YoutubeChannelDetailsPage();
}

class _YoutubeChannelDetailsPage extends State<YoutubeChannelDetailsPage> {
  final NumberFormat nf = NumberFormat.simpleCurrency(decimalDigits: 0, name: 'JPY', locale: 'en_US');
  final TextStyle textStyle = const TextStyle(fontSize: 18);
  final TextStyle titleTextStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  final EdgeInsets basicSpacing = const EdgeInsets.only(top: 10, bottom: 10);

  @override
  Widget build(BuildContext context) {
    YoutubeChannel youtubeChannel = widget.youtubeChannel;
    String description = widget.description;

    String formattedSubscriberCount =
    nf.format(youtubeChannel.subscriberCount).substring(1);
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double sliverExpandedHeight = width - Get.statusBarHeight;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Uri url = Uri(
              scheme: 'https',
              host: 'www.youtube.com',
              path: 'channel/${youtubeChannel.channelId}',
              queryParameters: {
                'sub_confirmation': 1,
              }
          );
          launchUrl(url);
        },
        tooltip: "Open ${youtubeChannel.channelName} in Youtube",
        child: Image.asset('assets/images/youtube_icon.png'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: sliverExpandedHeight,
            floating: false,
            pinned: true,
            primary: true,
            backgroundColor: theme.primaryColor,
            iconTheme: theme.iconTheme,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                youtubeChannel.channelName,
                style: theme.appBarTheme.titleTextStyle
              ),
              background: Hero(
                tag: '${youtubeChannel.channelId}_picture',
                child: Container(
                  padding: EdgeInsets.all(width * 0.20),
                  child: YoutubeChannel.getProfilePicture(youtubeChannel.channelId, 0),
                ),
              ),
            ),
            toolbarTextStyle: theme.textTheme.bodyText2,
            titleTextStyle: theme.textTheme.headline6,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Container(
                color: theme.backgroundColor,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: basicSpacing,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Description:', style: titleTextStyle),
                            Text(description, style: textStyle),
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
          )
        ],
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

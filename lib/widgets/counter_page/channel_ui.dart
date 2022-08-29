import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pdp_vs_ts_v3/constants/general.dart';
import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/pages/youtube_channel_details_page.dart';
import 'package:pdp_vs_ts_v3/widgets/counter.dart';

import '../channel_preview.dart';

class ChannelUI extends StatelessWidget {
  final YoutubeChannel youtubeChannel;
  final textStyle = const TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, fontFamily: "Roboto");
  final defaultMargin = const EdgeInsets.fromLTRB(0, 10, 0, 0);

  const ChannelUI({Key? key, required this.youtubeChannel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String channelName = youtubeChannel.channelName;
    int subscriberCount = youtubeChannel.subscriberCount;

    if (channelName == '') {
      return Container();
    }

    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ChannelPreview(
              youtubeChannel: youtubeChannel,
              onClick: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => YoutubeChannelDetailsPage(youtubeChannel: youtubeChannel))
                );
              },
            ),
            Container(
              margin: defaultMargin,
              child: CounterWidget(value: subscriberCount, textStyle: textStyle),
            )
          ],
        ));
  }
}

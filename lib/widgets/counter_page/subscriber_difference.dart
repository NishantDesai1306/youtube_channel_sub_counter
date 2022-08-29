import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';

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
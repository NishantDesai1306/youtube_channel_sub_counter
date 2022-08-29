import 'package:flutter/material.dart';

import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';

import 'package:pdp_vs_ts_v3/model/youtube_channel.dart';
import 'package:pdp_vs_ts_v3/utils/index.dart';

class ChannelPreview extends StatelessWidget {
  final YoutubeChannel youtubeChannel;
  final Function onClick;
  final bool shouldRenderEmpty;

  final textStyle = const TextStyle(
      fontSize: 25.0, fontWeight: FontWeight.bold, fontFamily: "Roboto");
  final defaultMargin = const EdgeInsets.fromLTRB(0, 10, 0, 0);

  const ChannelPreview({
    Key? key,
    required this.youtubeChannel,
    required this.onClick,
    this.shouldRenderEmpty = false,
  }) : super(key: key);

  void onTap() {
    onClick();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double width = getLayoutWidth(context);
    double imageDimension = width * 0.4;
    double borderWidth = 5;

    if (youtubeChannel.channelId.isEmpty && !shouldRenderEmpty) {
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
                  tag: "${youtubeChannel.channelId}_picture",
                  child: GestureDetector(
                    onDoubleTap: () {},
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(
                              imageDimension / 2 + borderWidth),
                          border: Border.all(
                              color: theme.primaryColor, width: borderWidth)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(imageDimension / 2),
                        child: youtubeChannel.channelId.isNotEmpty
                            ? TransitionToImage(
                              image: AdvancedNetworkImage(youtubeChannel.channelPicture),
                              loadingWidget: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                              ),
                              fit: BoxFit.cover,
                              width: imageDimension,
                            )
                            : SizedBox(
                          height: imageDimension,
                          width: imageDimension,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: defaultMargin,
              child: Text(
                youtubeChannel.channelName,
                style: textStyle,
              ),
            )
          ],
        ));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
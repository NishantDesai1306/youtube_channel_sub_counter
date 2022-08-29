import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";

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
                  Checkbox(
                    activeColor: theme.primaryColor,
                    onChanged: (bool? isChecked) {
                      setState(() {
                        dontShowAgain = isChecked ?? false;
                      });
                    },
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

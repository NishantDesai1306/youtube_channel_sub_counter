import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  final String title, message;

  const ConfirmDialog(
      {Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  State<ConfirmDialog> createState() =>
      ConfirmDialogState();
}

class ConfirmDialogState extends State<ConfirmDialog> {
  ConfirmDialogState();

  void onSubmit(bool wasConfirmed) {
    return Navigator.of(context).pop(wasConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle textStyle = TextStyle(color: theme.textTheme.bodyText1?.color);

    return SimpleDialog(
      title: Text(widget.title, style: textStyle),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              Text(widget.message, style: textStyle),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton(
              child: Text("No", style: textStyle),
              onPressed: () {
                onSubmit(false);
              },
            ),
            TextButton(
              child: Text("Yes", style: textStyle),
              onPressed: () {
                onSubmit(true);
              },
            )
          ],
        )
      ],
    );
  }
}

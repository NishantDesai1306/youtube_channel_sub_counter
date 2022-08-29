import 'package:flutter/material.dart';
import 'package:pdp_vs_ts_v3/utils/index.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  const ResponsiveContainer({Key? key, required this.child}): super(key: key);

  @override
  Widget build(BuildContext context) {
    double layoutWidth = getLayoutWidth(context);

    return Container(
        constraints: BoxConstraints(maxWidth: layoutWidth),
        child: child
    );
  }
}

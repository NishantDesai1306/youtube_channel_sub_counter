import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdp_vs_ts_v3/constants/strings.dart';
import 'package:pdp_vs_ts_v3/pages/settings.dart';

import '../utils/index.dart';
import '../widgets/responsive_container.dart';
import 'counter_page.dart';

class MainPage extends StatefulWidget {
  static const String route = '/main';

  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool isSettingsOpen = false;

  void toggleSettingsPage() {
    if (isSettingsOpen) {
      setState(() {
        isSettingsOpen = false;
      });
    } else {
      setState(() {
        isSettingsOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          iconTheme: theme.iconTheme,
          centerTitle: true,
          title: Text(APP_NAME),
          actions: <Widget>[
            IconButton(
              tooltip: APP_SETTINGS,
              onPressed: toggleSettingsPage,
              icon: Icon(isSettingsOpen ? Icons.close : Icons.settings),
            )
          ],
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          alignment: Alignment.center,
          child: MainPagePanels(
                panelToRender: isSettingsOpen
                    ? MainPagePanels.SETTINGS_PANEL
                    : MainPagePanels.COUNTER_PANEL),
          ),
    );
  }
}

class MainPagePanels extends StatefulWidget {
  final String panelToRender;
  static const double HEADER_HEIGHT = 300;
  static const String SETTINGS_PANEL = 'SETTINGS_PANEL';
  static const String COUNTER_PANEL = 'COUNTER_PANEL';

  const MainPagePanels({Key? key, required this.panelToRender})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPagePanels();
}

class _MainPagePanels extends State<MainPagePanels>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  String panelAtTop = MainPagePanels.COUNTER_PANEL;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500), value: 1);
  }

  @override
  void didUpdateWidget(MainPagePanels oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (panelAtTop != widget.panelToRender) {
      panelAtTop = widget.panelToRender;

      double velocity =
          widget.panelToRender == MainPagePanels.SETTINGS_PANEL ? -1 : 1;

      animationController.fling(velocity: velocity);
    }
  }

  Animation<RelativeRect> getPanelAnimation(BoxConstraints boxConstraints) {
    final height = boxConstraints.biggest.height;
    final settingsPageHeight = height - MainPagePanels.HEADER_HEIGHT;
    const counterPageHeight = -MainPagePanels.HEADER_HEIGHT;

    final RelativeRectTween tween = RelativeRectTween(
        begin:
            RelativeRect.fromLTRB(0, settingsPageHeight, 0, counterPageHeight),
        end: const RelativeRect.fromLTRB(0, 0, 0, 0));

    final CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.linear);

    return tween.animate(curvedAnimation);
  }

  Widget renderPanels(BuildContext context, BoxConstraints boxConstraints) {
    return Stack(
      children: <Widget>[
        const SettingsPage(),
        PositionedTransition(
          rect: getPanelAnimation(boxConstraints),
          child: ResponsiveContainer(
            child: CounterPage(
              isSettingsOpen:
                  widget.panelToRender == MainPagePanels.SETTINGS_PANEL)
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: renderPanels,
    );
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }
}

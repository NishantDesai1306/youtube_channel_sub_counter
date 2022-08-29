import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:pdp_vs_ts_v3/pages/set_channels.dart';
import 'package:pdp_vs_ts_v3/widgets/confirm_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:pdp_vs_ts_v3/constants/theme.dart';
import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';
import 'package:pdp_vs_ts_v3/pages/about_me.dart';

class SettingsPage extends StatefulWidget {
  static const String route = "/settings";

  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int subscriberDifference = 0;
  int themeId = AppThemes.light;

  String subscriberDifferencePreferenceKey =
      SharedPreferenceHelper.getSubscriberDifferenceKey();
  String themeIdKey = SharedPreferenceHelper.getThemeId();

  SettingsPageState() {
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      setState(() {
        subscriberDifference =
            sp.getInt(subscriberDifferencePreferenceKey) ?? 0;
        themeId = sp.getInt(themeIdKey) ?? AppThemes.light;
      });
    });
  }

  onDarkThemeToggleChange(bool useDarkTheme) async {
    var dynamicTheme = DynamicTheme.of(context);
    print('use dark theme ${useDarkTheme.toString()}');
    int newTheme = useDarkTheme ? AppThemes.dark : AppThemes.light;
    SharedPreferences sp = await SharedPreferences.getInstance();

    // change theme
    dynamicTheme?.setTheme(newTheme);

    // setting brightness even after setting theme because this lib checks shared preferences for key isDark
    sp.setInt(themeIdKey, newTheme);

    setState(() {
      themeId = newTheme;
    });
  }

  void clearChannelData () async {
    bool? wasConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) =>
            const ConfirmDialog(title: "Clear channel data", message: "Are you sure you want to clear saved channels"));

    if (wasConfirmed == true) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      List<String>? channels = sp.getStringList(SharedPreferenceHelper.getSelectedChannelIdsKey());

      if (channels != null) {
        channels.forEach((channelId) {
          sp.remove(SharedPreferenceHelper.getNameKey(channelId));
          sp.remove(SharedPreferenceHelper.getDescriptionKey(channelId));
          sp.remove(SharedPreferenceHelper.getProfilePictureKey(channelId));
          sp.remove(SharedPreferenceHelper.getSubscribersKey(channelId));
        });

        sp.remove(SharedPreferenceHelper.getSubscriberDifferenceKey());
        sp.remove(SharedPreferenceHelper.getSelectedChannelIdsKey());
      }

      Navigator.of(context).pushReplacementNamed(SetChannels.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    const settingCategoryTitle = TextStyle(
      color: Colors.white,
      fontSize: 13,
    );
    const settingTitle = TextStyle(color: Colors.white, fontSize: 15);
    const categoryTitleBottomMargin = EdgeInsets.only(bottom: 20);
    const settingsTitleBottomMargin = EdgeInsets.only(bottom: 5);

    return Container(
      padding: const EdgeInsets.all(15),
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: categoryTitleBottomMargin,
                      child: const Text("Theme", style: settingCategoryTitle),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: settingsTitleBottomMargin,
                          child: const Text("Dark Theme", style: settingTitle),
                        ),
                        Switch(
                          activeColor: lightTheme.primaryColor,
                          inactiveThumbColor: Colors.white,
                          onChanged: onDarkThemeToggleChange,
                          value: themeId == AppThemes.dark,
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white),

                    const SizedBox(height: 10),

                    Container(
                      margin: categoryTitleBottomMargin,
                      child: Text("Channels", style: settingCategoryTitle),
                    ),
                    Container(
                      margin: settingsTitleBottomMargin,
                      child: InkWell(
                        onTap: clearChannelData,
                        child: const Expanded(
                          child: Text("Clear channel data", style: settingTitle),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white),

                    const SizedBox(height: 10),

                    Container(
                      margin: settingsTitleBottomMargin,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(AboutMePage.route);
                        },
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: settingsTitleBottomMargin,
                                    child: const Text("About Me", style: settingTitle),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
              ))
            ],
          )
        ],
      ),
    );
  }
}

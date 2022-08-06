import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pdp_vs_ts_v3/constants/theme.dart';
import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';

import 'about_me.dart';

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
      SharedPreferenceHelper.getSubscriberDiffernceKey();
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
                    const Divider(
                      color: Colors.white,
                      height: 30,
                    ),
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
                                    child: const Text("About Me",
                                        style: settingTitle),
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

import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pdp_vs_ts_v3/helpers/shared_preference_helper.dart';
import 'package:pdp_vs_ts_v3/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Duration pageChangeAnimationDuration = Duration(milliseconds: 250);
Curve pageChangeAnimationCurve = Curves.linear;

class AppExplanation extends StatefulWidget {
  static String route = '/explanation';

  const AppExplanation({Key? key}) : super(key: key);
  _AppExplanationState createState() => _AppExplanationState();
}

class _AppExplanationState extends State<AppExplanation> {
  int _currentPage = 0;
  CarouselController carouselController = CarouselController();

  _AppExplanationState() {
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      String key = SharedPreferenceHelper.getAppExplanationKey();
      sp.setBool(key, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    double bottomButtonBarHeight = screenSize.height * 0.075;

    final CarouselSlider slider = CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 1,
        onPageChanged: (currentPageIndex, reason) {
          setState(() {
            _currentPage = currentPageIndex;
          });
        },
      ),
      carouselController: carouselController,
      items: [
        Stack(
          alignment: Alignment.center,
          children: const <Widget>[
            FlareActor(
              'assets/flares/counter.flr',
              animation: "counter",
              fit: BoxFit.cover,
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: const <Widget>[
            FlareActor(
              'assets/flares/screenshot.flr',
              animation: "screenshot",
              fit: BoxFit.cover,
            ),
          ],
        ),
      ],
    );

    String message = _currentPage == 0
        ? "Check the subscriber count live."
        : "Tap and hold on main page to share screenshot with your contacts.";

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Column(children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          height: screenSize.height - bottomButtonBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              slider,
              Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Text(message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: theme.primaryColor, fontSize: 20)),
                  ),
                  PageIndicator(carouselController: carouselController, currentPage: _currentPage)
                ],
              )
            ],
          ),
        ),
        BottomButtonBar(
          itemCount: 2,
            bottomButtonBarHeight: bottomButtonBarHeight,
            carouselController: carouselController,
            currentPageIndex: _currentPage)
      ]),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    Key? key,
    required this.carouselController,
    required int currentPage,
  })  : _currentPage = currentPage,
        super(key: key);

  final CarouselController carouselController;
  final int _currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkResponse(
          radius: 0,
          onTap: () {
            carouselController.animateToPage(0,
                curve: pageChangeAnimationCurve,
                duration: pageChangeAnimationDuration);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 0 ? Colors.white : Colors.grey,
            ),
            margin: const EdgeInsets.only(right: 10),
            height: 15,
            width: 15,
          ),
        ),
        InkResponse(
          radius: 0,
          onTap: () {
            carouselController.animateToPage(1,
                curve: pageChangeAnimationCurve,
                duration: pageChangeAnimationDuration);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == 1 ? Colors.white : Colors.grey,
            ),
            margin: const EdgeInsets.only(right: 10),
            height: 15,
            width: 15,
          ),
        ),
      ],
    );
  }
}

class BottomButtonBar extends StatelessWidget {
  final CarouselController carouselController;
  final double bottomButtonBarHeight;
  final int currentPageIndex;
  final double buttonWidth = 150;
  final int itemCount;

  const BottomButtonBar({
    Key? key,
    required this.itemCount,
    required this.bottomButtonBarHeight,
    required this.carouselController,
    required this.currentPageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isAtLastPage = currentPageIndex == itemCount - 1;
    bool isAtFirstPage = currentPageIndex == 0;

    return Container(
      decoration:
          const BoxDecoration(border: Border(top: BorderSide(color: Colors.white))),
      height: bottomButtonBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: bottomButtonBarHeight,
            width: buttonWidth,
            child: FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[Icon(Icons.chevron_left), Text("Previous")],
              ),
              onPressed: () {
                // current page is first page page
                if (!isAtFirstPage) {
                  carouselController.previousPage(
                      duration: pageChangeAnimationDuration,
                      curve: pageChangeAnimationCurve);
                }
              },
            ),
          ),
          Container(
            height: bottomButtonBarHeight,
            width: buttonWidth,
            child: FlatButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(isAtLastPage ? "Go to App" : "Next"),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onPressed: () {
                  if (isAtLastPage) {
                    Navigator.of(context).pushReplacementNamed(MainPage.route);
                  } else {
                    carouselController.nextPage(
                        duration: pageChangeAnimationDuration,
                        curve: pageChangeAnimationCurve);
                  }
                }),
          ),
        ],
      ),
    );
  }
}

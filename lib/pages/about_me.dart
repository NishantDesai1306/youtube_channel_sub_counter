import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMePage extends StatefulWidget {
  static String route = '/about';

  const AboutMePage({Key? key}) : super(key: key);
  
  @override
  AboutMePageState createState() => AboutMePageState();
}

double pageSpacing = 10;

class AboutMePageState extends State<AboutMePage> {
  AboutMePageState();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    const TextStyle textStyle = TextStyle(fontSize: 18);

    const TextStyle titleTextStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.iconTheme,
        title: const Text("About"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 350,
                  color: theme.primaryColor,
                  child: Image.asset('assets/images/logo.png'),
                ),
              )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(pageSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: pageSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            'About app:',
                            style: titleTextStyle,
                          ),
                          Text(
                            'This app is result of a pet project that I created in order to learn basics of Flutter SDK.',
                            style: textStyle,
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Developer:',
                          style: titleTextStyle,
                        ),
                        const Text(
                          'Nishant Desai',
                          style: textStyle,
                        ),
                        InkWell(
                          onTap: () {
                            Uri url = Uri(
                                scheme: 'mailto',
                                host: 'nishantdesai1306@gmail.com',
                            );
                            launchUrl(url);
                          },
                          child: const Text(
                            'nishantdesai1306@gmail.com',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                textBaseline: TextBaseline.ideographic),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const DonationSection()
        ],
      ),
    );
  }
}

class DonationSection extends StatefulWidget {
  const DonationSection({Key? key}) : super(key: key);

  @override
  DonationSectionState createState() => DonationSectionState();
}

class DonationSectionState extends State<DonationSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: pageSpacing, right: pageSpacing, bottom: pageSpacing / 2),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 1, color: Colors.grey),
        ),
        onPressed: () {
          Clipboard.setData(
              const ClipboardData(text: 'nishantdesai1306@gmail.com'));

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email address copied to your clipboard'),
            duration: Duration(seconds: 3),
          ));
        },
        child: const Text(
          "If you like this app, please consider supporting me through PayPal donations on nishantdesai1306@gmail.com",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

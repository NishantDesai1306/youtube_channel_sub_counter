import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CounterWidget extends StatefulWidget {
  final int value;
  final TextStyle textStyle;

  const CounterWidget({Key? key, required this.value, required this.textStyle}): super(key: key);

  @override
  CounterState createState() => CounterState();
}

class CounterState extends State<CounterWidget> {
  static const int UPDATE_FREQUENCY = 20;
  int counter = 0;

  Timer timer = Timer.periodic(const Duration(days: 1), (timer) { });
  NumberFormat nf = NumberFormat.simpleCurrency(decimalDigits: 0, name: 'JPY', locale: 'en_US');

  formatNumber(int value) {
    return nf.format(value).substring(1);
  }

  @override
  void didUpdateWidget(CounterWidget oldWidget) {
    if (timer.isActive) {
      setState(() {
        counter = oldWidget.value;
      });
      timer.cancel();
    }

    timer = Timer.periodic(const Duration(milliseconds: UPDATE_FREQUENCY), updateCounter);
    super.didUpdateWidget(oldWidget);
  }

  setFinalValue() {
    setState(() {
      counter = widget.value;
    });
  }

  void updateCounter(Timer timer) {
    if (counter == widget.value) {
      setFinalValue();
      timer.cancel();
      return;
    }

    int difference =  widget.value - counter;
    int delta = difference < 0 ? -1 : 1;

    setState(() {
      counter +=  delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedCounter = formatNumber(counter);
    return Text(
      formattedCounter,
      style: widget.textStyle,
    );
  }
}

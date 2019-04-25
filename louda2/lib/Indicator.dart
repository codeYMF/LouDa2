import 'package:flutter/material.dart';

class Indicator extends StatefulWidget {
  IndicatorController controller;

  Indicator(IndicatorController controller) : this.controller = controller;

  @override
  IndicatorState createState() => IndicatorState();
}

class IndicatorState extends State<Indicator> {
  bool isHidden = true;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      isHidden = widget.controller.value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      child: isHidden
          ? null
          : Offstage(
        offstage: isHidden,
        child: LinearProgressIndicator(
          backgroundColor: Colors.blue,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ),
    );
  }
}

class IndicatorController extends ValueNotifier<bool> {
  IndicatorController({bool isHidden = true}) : super(isHidden);

  bool get isHidden => value;
  set isHidden(bool hidden) {
    value = hidden;
  }
}
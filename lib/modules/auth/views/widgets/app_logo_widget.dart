import 'package:fleet_pulse/utlis/const/const_imports.dart';
import 'package:flutter/material.dart';

Widget applogoWidget() {
  return Image.asset("assets/logo.png")
      .box
      .padding(const EdgeInsets.all(8))
      .size(95, 95)
      .make();
}

import 'package:fleet_pulse/utlis/const/colors.dart';
import 'package:fleet_pulse/utlis/const/const_imports.dart';
import 'package:flutter/material.dart';



Widget homebuttons({width, height, icon, String? title, onPress}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(icon, width: 33),
      10.heightBox,
      title!.text.fontWeight(FontWeight.w600).color(darkFontGrey).make(),
    ],
  ).box.rounded.color(whiteColor).shadowSm.size(width, height).make();
}

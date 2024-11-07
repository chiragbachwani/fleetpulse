import 'package:fleet_pulse/utlis/const/const_imports.dart';
import 'package:fleet_pulse/utlis/const/styles.dart';
import 'package:flutter/material.dart';


Widget ourButton({onPress, color, textColor, String? title, shape}) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: shape,
        backgroundColor: color,
        padding: const EdgeInsets.all(12),
      ),
      onPressed: onPress,
      child: title!.text.color(textColor).fontFamily(bold).make());
}

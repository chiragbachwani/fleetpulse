
import 'package:fleet_pulse/utlis/const/colors.dart';
import 'package:fleet_pulse/utlis/const/styles.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';


Widget customTextField(
    {String? title, String? hint, TextEditingController? controller
, bool dontShow = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title!.text
          .color(Vx.blue900)
          .size(16)
          .fontWeight(FontWeight.bold)
          .fontFamily(bold)
          .make(),
      5.heightBox,
      TextFormField(
        controller: controller,
        obscureText: dontShow,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
          hintStyle: const TextStyle(
            fontSize: 16,
            fontFamily: semibold,
            color: textfieldGrey,
          ),
          hintText: hint,
          isDense: true,
          fillColor: lightGrey,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Vx.blue400),
          ),
        ),
      ),
    ],
  );
}

import 'package:fleet_pulse/controllers/auth_controller.dart';
import 'package:fleet_pulse/modules/admin/views/admin_dashborad_view.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/app_logo_widget.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/bg_widget.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/custom_textfield.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/our_button.dart';
import 'package:fleet_pulse/utlis/const/colors.dart';
import 'package:fleet_pulse/utlis/const/const_imports.dart';
import 'package:fleet_pulse/utlis/const/strings.dart';
import 'package:fleet_pulse/utlis/const/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool? isCheck = false;
  String role = "Driver"; // Default role
  final AuthController controller = Get.put(AuthController());

  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController repasscontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: [
              (context.screenHeight * 0.07).heightBox,
              applogoWidget(),
              5.heightBox,
              "Sign up to FleetPulse"
                  .text
                  .fontFamily(bold)
                  .fontWeight(FontWeight.w400)
                  .size(18)
                  .make(),
              10.heightBox,
              Obx(
                () => Column(
                  children: [
                    customTextField(
                      title: name,
                      hint: namehint,
                      controller: namecontroller,
                      dontShow: false,
                    ),
                    customTextField(
                      title: email,
                      hint: emailHint,
                      controller: emailcontroller,
                      dontShow: false,
                    ),
                    customTextField(
                      title: password,
                      hint: passhint,
                      controller: passwordcontroller,
                      dontShow: true,
                    ),
                    customTextField(
                      title: retypepass,
                      hint: passhint,
                      controller: repasscontroller,
                      dontShow: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: forgetpassword.text.color(Vx.blue500).make(),
                      ),
                    ),
                    5.heightBox,
                    // Role Selection
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text("Admin"),
                    //     Radio<String>(
                    //       value: "Admin",
                    //       groupValue: role,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           role = value!;
                    //         });
                    //       },
                    //     ),
                    //     Text("Driver"),
                    //     Radio<String>(
                    //       value: "Driver",
                    //       groupValue: role,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           role = value!;
                    //         });
                    //       },
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Checkbox(
                          value: isCheck,
                          onChanged: (newValue) {
                            setState(() {
                              isCheck = newValue;
                            });
                          },
                          checkColor: whiteColor,
                          activeColor: Vx.blue700,
                        ),
                        1.widthBox,
                        Expanded(
                          child: RichText(
                            text: const TextSpan(children: [
                              TextSpan(
                                text: "I agree to the ",
                                style: TextStyle(
                                  fontFamily: bold,
                                  color: fontGrey,
                                ),
                              ),
                              TextSpan(
                                text: termsAndCond,
                                style: TextStyle(
                                  fontFamily: bold,
                                  color: Color.fromARGB(255, 26, 157, 184),
                                ),
                              ),
                              TextSpan(
                                text: " & ",
                                style: TextStyle(
                                  fontFamily: bold,
                                  color: fontGrey,
                                ),
                              ),
                              TextSpan(
                                text: privacypolicy,
                                style: TextStyle(
                                  fontFamily: bold,
                                  color: Color.fromARGB(255, 26, 157, 184),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    controller.isLoading.value
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(turquoiseColor),
                          )
                        : ourButton(
                            color: isCheck == true
                                ? const Color.fromARGB(255, 26, 157, 184)
                                : lightGrey,
                            title: signup,
                            textColor: whiteColor,
                            onPress: () async {
                              controller.isLoading(true);
                              if (isCheck != false) {
                                try {
                                  await controller
                                      .signupMethod(
                                        context: context,
                                        email: emailcontroller.text,
                                        password: passwordcontroller.text,
                                        name: namecontroller.text,
                                        role: role,
                                      )
                                      .then((value) {
                                    VxToast.show(context, msg: loggedin);
                                    Get.offAll(() => const AdminDashboardView());
                                  });
                                } catch (e) {
                                  controller.isLoading(false);
                                  VxToast.show(context, msg: e.toString());
                                }
                              } else {
                                controller.isLoading(false);
                              }
                            },
                          ).box.width(context.screenWidth - 50).make(),
                    5.heightBox,
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: alreadyhaveAnAccount,
                            style: TextStyle(color: fontGrey),
                          ),
                          TextSpan(
                            text: login,
                            style: TextStyle(
                              color: turquoiseColor,
                              fontFamily: bold,
                            ),
                          ),
                        ],
                      ),
                    ).onTap(() {
                      Get.back();
                    }),
                  ],
                )
                    .box
                    .rounded
                    .padding(const EdgeInsets.all(16))
                    .width(context.screenWidth - 70)
                    .white
                    .shadowSm
                    .make(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:fleet_pulse/controllers/auth_controller.dart';
import 'package:fleet_pulse/modules/admin/views/admin_dashborad_view.dart';
import 'package:fleet_pulse/modules/auth/views/signin_view.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/app_logo_widget.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/bg_widget.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/custom_textfield.dart';
import 'package:fleet_pulse/modules/auth/views/widgets/our_button.dart';
import 'package:fleet_pulse/utlis/const/colors.dart';
import 'package:fleet_pulse/utlis/const/const_imports.dart';
import 'package:fleet_pulse/utlis/const/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScren extends StatelessWidget {
  const LoginScren({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());

    return bgWidget(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          children: [
            (context.screenHeight * 0.07).heightBox,
            applogoWidget(),
            5.heightBox,
            "Log in to $appname".text.color(Vx.white).bold.size(18).make(),
            10.heightBox,
            Obx(
              () => Column(
                children: [
                  customTextField(
                      title: email,
                      hint: emailHint,
                      controller: controller.emailController,
                      dontShow: false),
                  customTextField(
                      title: password,
                      hint: passhint,
                      controller: controller.passwordController,
                      dontShow: true),
                 
                  5.heightBox,
                  controller.isLoading.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(turquoiseColor),
                        )
                      : ourButton(
                          color: turquoiseColor,
                          title: login,
                          textColor: whiteColor,
                          onPress: () async {
                            controller.isLoading(true);
                            await controller
                                .loginMethod(context)
                                .then((value) {
                              if (value != null) {
                                VxToast.show(context, msg: loggedin);
                                Get.offAll(() => const AdminDashboardView());
                              } else {
                                controller.isLoading(false);
                              }
                            });
                          }).box.width(context.screenWidth - 50).make(),
                  5.heightBox,
                  creatnewaccount.text.color(fontGrey).make(),
                  5.heightBox,
                  ourButton(
                      color: Vx.blue100,
                      title: signup,
                      textColor: const Color.fromARGB(255, 26, 157, 184),
                      onPress: () {
                        Get.to(() => const SignupScreen());
                      }).box.width(context.screenWidth - 50).make(),
                  10.heightBox,
                  
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
    ));
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../Services/api_services.dart';
import '../../utils/Utils.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes/routes_names.dart';
import '../../utils/widget/button.dart';
import '../../utils/widget/customTextFields.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final apiServices = ApiService();

  bool isEmailValid(String email) {
    String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(emailRegex).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          decoration: BoxDecoration(color: AppColor.backgroundColor),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                      right: 0, child: Image.asset('assets/ellipse.png')),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              FadeInUp(
                                duration: const Duration(milliseconds: 1000),
                                child: const Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1300),
                                child: const Text(
                                  "Enter Your Company Detail to get started.",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .7,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: FadeInUp(
                              duration: const Duration(milliseconds: 1400),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: emailController,
                                      inputType: TextInputType.emailAddress,
                                      hintText: 'Email',
                                      prefixIcon: const Icon(Icons.email),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    CustomPasswordTextField(
                                        controller: passwordController,
                                        hintText: 'Password'),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: const Text('Forgot Password?'),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    button(
                                        width: 200,
                                        text: 'Login',
                                        onPress: () {
                                          setState(() {
                                            apiServices.loading = true;
                                          });

                                          if (emailController.text.isEmpty) {
                                            Utils.flushBarMessage(
                                                'Email field is required',
                                                context);
                                            setState(() {
                                              apiServices.loading = false;
                                            });
                                          } else if (!isEmailValid(
                                              emailController.text.trim())) {
                                            Utils.flushBarMessage(
                                                'Please enter a valid email',
                                                context);
                                            setState(() {
                                              apiServices.loading = false;
                                            });
                                          } else if (passwordController
                                              .text.isEmpty) {
                                            Utils.flushBarMessage(
                                                'Password field is required',
                                                context);
                                            setState(() {
                                              apiServices.loading = false;
                                            });
                                          } else if (passwordController
                                                  .text.length <
                                              8) {
                                            Utils.flushBarMessage(
                                                'Password should contain at least 8 characters',
                                                context);
                                            setState(() {
                                              apiServices.loading = false;
                                            });
                                          } else {
                                            apiServices
                                                .loginCompany(
                                                    emailController.text,
                                                    passwordController.text,
                                                    context)
                                                .then((_) {
                                              Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  RoutesName.companyHomeScreen,
                                                  (route) => false);
                                              Utils.flushBarMessage(
                                                  "Successfully loggedin as company",
                                                  context);
                                            }).catchError((error) {
                                              Utils.flushBarMessage(
                                                  'Incorrect username/password or user does not exist',
                                                  context);
                                            }).whenComplete(() {
                                              setState(() {
                                                apiServices.loading = false;
                                              });
                                            });
                                          }
                                        }),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Don't have an account ? ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacementNamed(
                                                  context,
                                                  RoutesName
                                                      .companyRegistrationScreen);
                                            },
                                            child: const Text('SignUp'))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (apiServices.loading)
          Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent background
            child: Center(
              child: Center(
                child: LoadingAnimationWidget.waveDots(
                  color: AppColor.primaryColor,
                  size: 80,
                ),
              ),
            ),
          ),
      ],
    ));
  }
}

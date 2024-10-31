import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../Services/api_services.dart';
import '../../utils/Utils.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes/routes_names.dart';
import '../../utils/widget/button.dart';
import '../../utils/widget/customTextFields.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  State<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final apiServices = ApiService();

  bool isEmailValid(String email) {
    String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    return RegExp(emailRegex).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color:AppColor.backgroundColor
        ),

        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Positioned(
                    left:0, child: Image.asset('assets/left_ellipse.png')),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 1000),
                              child: const Text(
                                "Create Company Account",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1300),
                              child: const Text(
                                "Let's Create Account Together",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20,),
          
                      Container(
                        height: MediaQuery.of(context).size.height*.7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: nameController,
                                    inputType: TextInputType.name,
                                    hintText: 'Name',
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomTextField(
                                    controller: emailController,
                                    inputType: TextInputType.emailAddress,
                                    hintText: 'Email',
                                    prefixIcon: const Icon(Icons.email),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomPasswordTextField(
                                    controller: passwordController,
                                    hintText: 'Password',
                                  ),
                                  const SizedBox(height: 20),
                                  CustomPasswordTextField(
                                    controller: confirmPasswordController,
                                    hintText: 'Confirm Password',
                                  ),
                                  const SizedBox(height: 20),
                                  button(
                                    width: 200,
                                    text: 'Continue',
                                    onPress: () async {
                                      if (nameController.text.isEmpty) {
                                        Utils.flushBarMessage(
                                            'Name field is required', context);
                                      } else if (emailController.text.isEmpty) {
                                        Utils.flushBarMessage(
                                            'Email field is required', context);
                                      } else if (!isEmailValid(
                                          emailController.text.trim())) {
                                        Utils.flushBarMessage(
                                            'Please enter a valid email', context);
                                      } else if (passwordController.text.isEmpty) {
                                        Utils.flushBarMessage(
                                            'Password field is required', context);
                                      } else if (passwordController.text.length < 8) {
                                        Utils.flushBarMessage(
                                            'Password should contain at least 8 characters',
                                            context);
                                      } else if (passwordController.text !=
                                          confirmPasswordController.text) {
                                        Utils.flushBarMessage(
                                            'Password and Confirm Password must be same',
                                            context);
                                      } else {
          
                                        Navigator.pushNamed(context, RoutesName.companyRegistrationDetailScreen,
                                            arguments: {
                                              'name': nameController.text,
                                              'email': emailController.text,
                                              'password': passwordController.text,
                                            });
                                      }
                                    },
                                  ),
          
                                  const SizedBox(height: 60,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Already have an account?"),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                              context, RoutesName.companyLoginScreen);
                                        },
                                        child: const Text('Login'),
                                      )
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


      )
    );
  }
}

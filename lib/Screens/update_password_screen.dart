import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:style_nexus/utils/Utils.dart';
import 'package:style_nexus/utils/app_colors.dart';
import 'package:style_nexus/utils/widget/button.dart';
import 'package:style_nexus/utils/widget/customTextFields.dart';

import '../Services/api_services.dart';
import '../utils/routes/routes_names.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final ApiService apiService = ApiService();
  var _currentEmail;
  var _currentName;
  var _role;

  Future<Map<String, dynamic>> _fetchData() async {
    await apiService.refreshToken();
    final totalLimit = await apiService.fetchTotalQueryLimit();
    final limit = await apiService.fetchQueryCount();
    return {
      'totalLimit': totalLimit,
      'limit': limit,
    };
  }

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var totalLimit;
  var limit;

  Future<void> initialization() async {
    await apiService.refreshToken();
    totalLimit = await apiService.fetchTotalQueryLimit();
    limit = await apiService.fetchQueryCount();
  }

  Future<Map<String, dynamic>> _fetchCurrentUserData() async {
    initialization().then((_) {
      setState(() {});
    });
    final userData = await apiService.getcurrentUserData();
    return {
      'name': userData['name'],
      'email': userData['email'],
      'role': userData['role']
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData().then((userData) {
      setState(() {
        _currentName = userData['name'];
        _currentEmail = userData['email'];
        _role = userData['role'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
          ),
          actions: [
            _role == 'user'
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PopupMenuButton<int>(
                      onSelected: (value) async {
                        if (value == 1) {
                          Navigator.pushNamed(
                              context, RoutesName.subscriptionScreen);
                        } else if (value == 2) {
                          await apiService.logout(context);
                        }
                      },
                      icon: const Icon(
                          Icons.more_horiz), // Icon for the popup menu
                      itemBuilder: (context) => [
                        // Add a custom menu item for displaying the query information
                        PopupMenuItem<int>(
                          enabled:
                              false, // Disable this item to make it non-selectable
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _fetchData(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: LoadingAnimationWidget.waveDots(
                                        color: AppColor.primaryColor,
                                        size: 20));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData) {
                                return const Center(child: Text('Loading...'));
                              } else {
                                final data = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Total Queries: ${data['totalLimit'] ?? 'Loading'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Queries Used: ${data['limit'] ?? 'Loading'} '),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        // Actual menu items
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Subscription'),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PopupMenuButton<int>(
                      onSelected: (value) async {
                        if (value == 1) {
                          await apiService.logout(context);
                        }
                      },
                      icon: const Icon(
                          Icons.more_horiz), // Icon for the popup menu
                      itemBuilder: (context) => [
                        // Add a custom menu item for displaying the query information

                        // Actual menu items
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
        body: _currentName != null && _currentEmail != null
            ? SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Update Password',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                          controller: TextEditingController(text: _currentName),
                          readonly: true,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextField(
                          controller:
                              TextEditingController(text: _currentEmail),
                          readonly: true,
                          prefixIcon: const Icon(Icons.email),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomPasswordTextField(
                            controller: passwordController,
                            hintText: 'Password'),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomPasswordTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm Password'),
                        const SizedBox(
                          height: 40,
                        ),
                        button(
                            width: 200,
                            text: 'Update Password',
                            onPress: () {
                              if (passwordController.text.isEmpty) {
                                Utils.flushBarMessage(
                                    'Password is required', context);
                              } else if (passwordController.text.length < 8) {
                                Utils.flushBarMessage(
                                    'Password length must be greater than 8',
                                    context);
                              } else if (confirmPasswordController
                                  .text.isEmpty) {
                                Utils.flushBarMessage(
                                    'Confirm password is required', context);
                              } else if (passwordController.text !=
                                  confirmPasswordController.text) {
                                Utils.flushBarMessage(
                                    'Password and confirm password must be same',
                                    context);
                              } else {
                                apiService.updateUser(
                                    _currentName,
                                    _currentEmail,
                                    passwordController.text,
                                    context);
                              }
                            })
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: LoadingAnimationWidget.waveDots(
                    color: AppColor.primaryColor, size: 80),
              ));
  }
}

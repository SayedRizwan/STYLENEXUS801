import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:style_nexus/Services/api_services.dart';
import 'package:style_nexus/utils/widget/button.dart';
import 'package:style_nexus/utils/widget/customTextFields.dart';

import '../utils/app_colors.dart';
import '../utils/routes/routes_names.dart';

class ContactUsScreen extends StatefulWidget {
  final String? isCompany;  // Change to String

  const ContactUsScreen({super.key,this.isCompany});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final ApiService apiService= ApiService();

  final firstNameController =TextEditingController();
  final lastNameController =TextEditingController();
  final emailController =TextEditingController();
  final messageController =TextEditingController();

  var totalLimit;
  var limit;

  Future<Map<String, dynamic>> _fetchData() async {
    await apiService.refreshToken();
    final totalLimit = await apiService.fetchTotalQueryLimit();
    final limit = await apiService.fetchQueryCount();
    return {
      'totalLimit': totalLimit,
      'limit': limit,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PopupMenuButton<int>(
              onSelected: (value) async {
                if (widget.isCompany == 'true') {
                  if (value == 1) {
                    Navigator.pushNamed(context, RoutesName.subscriptionScreen);
                  } else if (value == 2) {
                    Navigator.pushNamed(context, RoutesName.updatePasswordScreen);
                  } else if (value == 3) {
                    await apiService.logout(context);
                  }
                } else if(widget.isCompany ==' false') {
                  if (value == 1) {
                    Navigator.pushNamed(context, RoutesName.updatePasswordScreen);
                  } else if (value == 2) {
                    await apiService.logout(context);
                  }
                }
              },

              icon: const Icon(Icons.more_horiz), // Icon for the popup menu
              itemBuilder: (context) => [

                if(widget.isCompany == 'true')...[
                  PopupMenuItem<int>(
                    enabled: false, // Disable this item to make it non-selectable
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: LoadingAnimationWidget.waveDots(color: AppColor.primaryColor, size: 20));
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData) {
                          return const Center(child: Text('Loading...'));
                        } else {
                          final data = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Queries: ${data['totalLimit'] ?? 'Loading'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Queries Used: ${data['limit'] ?? 'Loading'} '),
                              const SizedBox(height: 8),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Subscription'),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Update Password'),
                  ),

                  const PopupMenuItem<int>(
                    value: 3,
                    child: Text('Logout'),
                  ),
                ]
                else if(widget.isCompany == 'false')...[
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text('Update Password'),
                  ),

                  const PopupMenuItem<int>(
                    value: 2,
                    child: Text('Logout'),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              CustomTextField(controller: firstNameController, hintText: 'First Name', inputType: TextInputType.name, maxLine: 1,),
              const SizedBox(height: 10,),
              CustomTextField(controller: lastNameController, hintText: 'Last Name', inputType: TextInputType.name, maxLine: 1,),
              const SizedBox(height: 10,),
              CustomTextField(controller: emailController, hintText: 'Email', inputType: TextInputType.emailAddress, maxLine: 1,),
              const  SizedBox(height: 10,),
              CustomTextField(controller: messageController, hintText: 'Message', inputType: TextInputType.multiline, maxLine: 5,),
        
              const SizedBox(height: 30,),
              
              button(width: 230, text: 'Submit', onPress: (){
                apiService.feedback(firstNameController.text, lastNameController.text, emailController.text, messageController.text, context).whenComplete(
                    (){
                      setState(() {
                        firstNameController.clear();
                        lastNameController.clear();
                        emailController.clear();
                        messageController.clear();
                      });
                    }
                ); }),
        
            ],
          ),
        ),
      ),
    );
  }
}

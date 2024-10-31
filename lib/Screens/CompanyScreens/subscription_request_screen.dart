import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:style_nexus/Services/api_services.dart';
import 'package:style_nexus/utils/app_colors.dart';
import 'package:style_nexus/utils/widget/button.dart';

import '../../utils/routes/routes_names.dart';

class SubscriptionRequestScreen extends StatefulWidget {
  final String planType;

  const SubscriptionRequestScreen({super.key, required this.planType});

  @override
  State<SubscriptionRequestScreen> createState() => _SubscriptionRequestScreenState();
}

class _SubscriptionRequestScreenState extends State<SubscriptionRequestScreen> {

  final ApiService apiService = ApiService();
  var _currentEmail;
  var _currentName;
  var _currentPlan;
  var _subscriptionStatus;

  Future<Map<String, dynamic>> _fetchCurrentUserData() async {
    final userData = await apiService.getcurrentUserData();
    return {
      'name': userData['name'],
      'email': userData['email'],
      'plan_name': userData['plan_name'],
      'subscription_status': userData['subscription_status'],
    };
  }

  var totalLimit;
  var limit;

  Future <void> initialization () async{
    await apiService.refreshToken();
    totalLimit= await apiService.fetchTotalQueryLimit();
    limit= await apiService.fetchQueryCount();
  }


  @override
  void initState() {
    super.initState();
    initialization().then((_){
      setState(() {
      });
    });

    _fetchCurrentUserData().then((userData) {
      setState(() {
        _currentName = userData['name'];
        _currentEmail = userData['email'];
        _currentPlan= userData['plan_name'];
        _subscriptionStatus= userData['subscription_status'];
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PopupMenuButton<int>(
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.pushNamed(context, RoutesName.updatePasswordScreen);
                }else if (value == 2){
                  await apiService.logout(context);

                }
              },
              icon: const Icon(Icons.more_horiz), // Icon for the popup menu
              itemBuilder: (context) => [
                // Add a custom menu item for displaying the query information
                PopupMenuItem<int>(
                  enabled: false, // Disable this item to make it non-selectable
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Queries: ${totalLimit??'Loading'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Queries Used: ${limit ?? 'Loading'} '),
                      const SizedBox(height: 8), // Spacer
                    ],
                  ),
                ),
                // Actual menu items

                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Update Password'),
                ),

                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _currentEmail != null && _currentName != null
          ? Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Request Information',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text('''
Dear Support Team,

I am writing to request an upgrade to my plan to ${widget.planType}. I have found the current query limit to be insufficient for my needs and would like to increase it to continue using your service effectively.

My name is $_currentName.
My current email address is $_currentEmail.
My Current plan is $_currentPlan.
My current subscription status is $_subscriptionStatus.

Thank you for your prompt attention to this matter.

Best regards,
                          '''),
                    const SizedBox(height: 30),
                    Center(
                      child: button(
                        width: 150,
                        text: 'Send Request',
                        onPress: () async {
                          final Email email = Email(
                            body: '''
Dear Support Team,

I am writing to request an upgrade to my plan to ${widget.planType}. I have found the current query limit to be insufficient for my needs and would like to increase it to continue using your service effectively.
My name is $_currentName.

My current email address is $_currentEmail.

Thank you for your prompt attention to this matter.

Best regards,
                                  ''',
                            subject: 'Query limit upgrade',
                            recipients: ['victoire.caussieup@gmail.com'],
                            isHTML: false,
                          );

                          String platformResponse;

                          try {
                            await FlutterEmailSender.send(email);
                            platformResponse = 'success';
                          } catch (error) {
                            print(error);
                            platformResponse = error.toString();
                          }

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(platformResponse),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: LoadingAnimationWidget.waveDots(color: AppColor.primaryColor, size: 80),
      ),
    );
  }
}

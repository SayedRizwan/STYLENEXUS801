import 'package:flutter/material.dart';
import 'package:style_nexus/Services/api_services.dart';
import 'package:style_nexus/utils/app_colors.dart';

import '../../utils/routes/routes_names.dart';
import '../../utils/widget/button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _basicKey = GlobalKey();
  final GlobalKey _standardKey = GlobalKey();
  final GlobalKey _premiumKey = GlobalKey();

  final ApiService apiService= ApiService();
  var totalLimit;
  var limit;

  Future <void> initialization () async{
    await apiService.refreshToken();
    totalLimit= await apiService.fetchTotalQueryLimit();
    limit= await apiService.fetchQueryCount();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialization().then((_){
      setState(() {
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width * .9,
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Try Our Demo',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const Text(
                          'Send us a request',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                        button(width: 130, text: 'Click here', onPress: () {
                          Navigator.pushNamed(context, RoutesName.subscriptionRequestScreen, arguments: 'Demo');
                        }),
                      ],
                    ),
                    Image.asset('assets/logo1.png'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TabContainer(
                  text: 'Basic Plan',
                  onPress: () => _scrollToSection(_basicKey),
                ),
                TabContainer(
                  text: 'Standard Plan',
                  onPress: () => _scrollToSection(_standardKey),
                ),
                TabContainer(
                  text: 'Premium Plan',
                  onPress: () => _scrollToSection(_premiumKey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              key: _basicKey,
              tab: const TabContainer(text: 'Basic Plan'),
              description: '''
Allow your customers to test their favorite clothes via their smartphone.

The +:
      - Automation of creation of augmented reality filter of clothing from photos
      - Up to 30% reduction in online order return rates
      - Customer loyalty thanks to virtual try-on
              ''',
              logoCount: 1,
            ),
            _buildSection(
              key: _standardKey,
              tab: const TabContainer(text: 'Standard Plan'),
              description: '''
In addition to the basic subscription, you will have the possibility to offer your customers intelligent recommendations and better control your stocks thanks to AI.

The +:
      - Increased customer engagement
      - More proximity to customers
      - Approximately 30% increase in sales
              ''',
              logoCount: 2,
            ),
            _buildSection(
              key: _premiumKey,
              tab: const TabContainer(text: 'Premium Plan'),
              description: '''
In addition to the features of other subscriptions, you will be able to access user data regarding their preferences, number of clicks, etc. Support assistance will be available 24/7.

You will also have the opportunity to offer advanced personalization to your customers such as automatic recommendations on the color and size of clothing best suited to each customer.

The +:
      - Customization of needs
      - More proximity to the customer
      - In-depth data analysis
              ''',
              logoCount: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required GlobalKey key,
    required Widget tab,
    required String description,
    required int logoCount,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              tab,
              const SizedBox(width: 20),
              Row(
                children: List.generate(
                  logoCount,
                      (index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset('assets/logo1.png', width: 50, height: 50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          // Add IconButton here
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.primaryColor, // Make sure AppColor.primaryColor is defined
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.subscriptionRequestScreen,
                    arguments: tab is TabContainer ? tab.text : 'Default Plan', // Pass the plan type
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class TabContainer extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;

  const TabContainer({
    super.key,
    required this.text,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffBEBEBE),
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

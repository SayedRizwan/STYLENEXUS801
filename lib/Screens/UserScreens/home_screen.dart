import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:style_nexus/Services/api_services.dart';
import 'package:style_nexus/utils/app_colors.dart';
import '../../utils/routes/routes_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Nexus'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PopupMenuButton<int>(
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.pushNamed(context, RoutesName.updatePasswordScreen);
                } else if (value == 2) {
                  Navigator.pushNamed(context, RoutesName.contactUsScreen,
                      arguments: {'isCompany': 'false'});
                } else if (value == 3) {
                  await apiService.logout(context);
                }
              },
              icon: const Icon(Icons.more_horiz), // Icon for the popup menu
              itemBuilder: (context) => const [
                PopupMenuItem<int>(
                  value: 1,
                  child: Text('Update Password'),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Text('Contact Us'),
                ),
                PopupMenuItem<int>(
                  value: 3,
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'COLLECTIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,

                  ),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: apiService.getAllCompanies(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: AppColor.primaryColor,
                        size: 80,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No companies found.'));
                  } else {
                    final companies = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Number of columns
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio:
                            0.85, // Adjusted ratio for better logo proportions
                      ),
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        String logoPath = company['logo_path'] ?? '';
                        logoPath =
                            logoPath.replaceFirst('company_data', 'clothes');
                        final logoUrl = 'http://54.197.126.5:8080/$logoPath';

                        return InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            RoutesName.productScreen,
                            arguments: {
                              'companyId': company['id'],
                              'imagePath': logoUrl,
                              'companyName': company['name'],
                            },
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            // Add padding for spacing
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              // Rounded corners
                              color: Colors.white,
                              // Background color for the logo container
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  // Soft shadow effect
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 3), // Shadow position
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // Center logo and company name
                              children: [
                                Expanded(
                                  child: Image.network(
                                    logoUrl,
                                    fit: BoxFit.contain, // Prevents stretching
                                    width: 100, // Define consistent width
                                    height: 100, // Define consistent height
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Space between image and text
                                Text(
                                  company['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  // Handle long names
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:style_nexus/Services/api_services.dart';
import 'package:style_nexus/utils/app_colors.dart';
import '../../utils/routes/routes_names.dart';

class ProductScreen extends StatefulWidget {
  final String companyId;
  final String imagePath;
  final String companyName;

  const ProductScreen({
    super.key,
    required this.companyId,
    required this.imagePath,
    required this.companyName,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.12, // Adjusted height for a better logo size
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 100,
                child: Image.network(
                  widget.imagePath, // Your company logo path
                  fit: BoxFit.contain, // Ensures the logo doesn't stretch
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.companyName,
                style: const TextStyle(color: Colors.black, fontSize: 18), // Styling company name
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PopupMenuButton<int>(
                onSelected: (value) async {
                  if (value == 1) {
                    Navigator.pushNamed(context, RoutesName.updatePasswordScreen);
                  } else if (value == 2) {
                    Navigator.pushNamed(context, RoutesName.contactUsScreen, arguments: {
                      'isCompany': 'false'
                    });
                  } else if (value == 3) {
                    await apiService.logout(context);
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.white),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(value: 1, child: Text('Update Password')),
                  const PopupMenuItem<int>(value: 2, child: Text('Contact Us')),
                  const PopupMenuItem<int>(value: 3, child: Text('Logout')),
                ],
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, String>>>(
            future: apiService.getAllMedia(widget.companyId, context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: LoadingAnimationWidget.waveDots(color: AppColor.primaryColor, size: 80));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No product found.'));
              } else {
                final images = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Adjust the number of columns as needed
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return InkWell(
                      onTap: () => Navigator.pushNamed(context, RoutesName.modelScreen, arguments: {
                        'productName': image['description'] ?? '',
                        'path': image['path'] ?? '',
                        'isCompany': false,
                        'companyName': widget.companyName ?? ''
                      }),
                      child: Stack(
                        children: [
                          Image.network(
                            'http://54.197.126.5:8080/${image['image_path']}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: LoadingAnimationWidget.waveDots(color: AppColor.primaryColor, size: 80));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error));
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                image['description'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            ),
        );
    }
}
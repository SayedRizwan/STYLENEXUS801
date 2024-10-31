import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:style_nexus/Services/api_services.dart';
import 'package:style_nexus/utils/app_colors.dart';
import 'package:style_nexus/utils/widget/button.dart';
import 'package:style_nexus/utils/widget/customTextFields.dart';
import '../../utils/Utils.dart';
import '../../utils/routes/routes_names.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen>
    with TickerProviderStateMixin {
  final productNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ApiService apiService = ApiService();

  File? image;
  bool isLoading = false;
  String? imagePath;
  late TabController _controller;
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
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PopupMenuButton<int>(
                onSelected: (value) async {
                  if (value == 1) {
                    Navigator.pushNamed(context, RoutesName.subscriptionScreen);
                  } else if (value == 2) {
                    Navigator.pushNamed(
                        context, RoutesName.updatePasswordScreen);
                  } else if (value == 3) {
                    Navigator.pushNamed(context, RoutesName.contactUsScreen,
                        arguments: {'isCompany': 'true'});
                  } else if (value == 4) {
                    await apiService.logout(context);
                  }
                },
                icon: const Icon(Icons.more_horiz), // Icon for the popup menu
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    enabled: false,
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _fetchData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: LoadingAnimationWidget.waveDots(
                                  color: AppColor.primaryColor, size: 20));
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
                    child: Text('Contact Us'),
                  ),
                  const PopupMenuItem<int>(
                    value: 4,
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            controller: _controller,
            tabs: const [
              Tab(icon: Icon(Icons.add), text: 'Add new product'),
              Tab(
                  icon: Icon(Icons.view_comfy_alt_outlined),
                  text: 'View products'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              child: TabBarView(
                controller: _controller,
                children: [
                  // Add Product Tab
                  _buildAddProductTab(),
                  // View Product Tab
                  _buildViewProductTab(),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black
                    .withOpacity(0.5), // Semi-transparent background
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingAnimationWidget.waveDots(
                        color: AppColor.primaryColor,
                        size: 80,
                      ),
                      const Text(
                        'Please wait it will take some time',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }

  Widget _buildAddProductTab() {
    return Column(
      children: [
        const SizedBox(height: 20),
        CustomTextField(
          controller: productNameController,
          hintText: 'Product Name',
          inputType: TextInputType.name,
        ),
        const SizedBox(height: 20),
        image == null ? _buildImagePickerCard() : _buildSelectedImageCard(),
        const SizedBox(height: 30),
        button(
          width: 200,
          text: 'Add Product',
          onPress: () async {
            if (productNameController.text.isEmpty) {
              Utils.flushBarMessage('Product name is required', context);
            } else if (image == null) {
              Utils.flushBarMessage('Please select product image', context);
            } else {
              setState(() {
                isLoading = true;
              });
              print('Image Path: $imagePath');
              await apiService.addCompanyProduct(
                  imagePath!, productNameController.text, context);

              setState(() {
                productNameController.clear();
                image = null;
                imagePath = null;
                isLoading = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildViewProductTab() {
    return FutureBuilder<List<Map<String, String>>>(
      future: apiService.fetch3DModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: LoadingAnimationWidget.waveDots(
                  color: AppColor.primaryColor, size: 80));
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
                onTap: () => Navigator.pushNamed(
                    context, RoutesName.modelScreen,
                    arguments: {
                      'productName': image['description'] ?? '',
                      'path': image['path'] ?? '',
                      'isCompany': true,
                      'companyName': ''
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
                        return Center(
                            child: LoadingAnimationWidget.waveDots(
                                color: AppColor.primaryColor, size: 80));
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
    );
  }

  Widget _buildImagePickerCard() {
    return Center(
      child: InkWell(
        onTap: _pickImage,
        child: Card(
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DottedBorder(
              dashPattern: const [8, 4],
              strokeWidth: 1,
              color: Colors.grey,
              strokeCap: StrokeCap.round,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width * .9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, color: Colors.grey, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Tap to select image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImageCard() {
    return Center(
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width * .9,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
          child: ClipRect(child: Image.file(image!)),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Services/api_services.dart';
import '../../utils/Utils.dart';
import '../../utils/app_colors.dart';
import '../../utils/routes/routes_names.dart';
import '../../utils/widget/button.dart';
import '../../utils/widget/customTextFields.dart';

class CompanyRegistrationDetailScreen extends StatefulWidget {
  const CompanyRegistrationDetailScreen({super.key});

  @override
  State<CompanyRegistrationDetailScreen> createState() => _CompanyRegistrationDetailScreenState();
}

class _CompanyRegistrationDetailScreenState extends State<CompanyRegistrationDetailScreen> {

  File? image;
  var imagePath;
  final ImagePicker _picker = ImagePicker();

  final taglineController = TextEditingController();
  final descriptionController = TextEditingController();
  final apiServices = ApiService();
  String? name;
  String? email;
  String? password;


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        image = File(pickedFile.path);

      });
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {

    final args= ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>){
      name= args['name'] as String;
      email = args['email'] as String;
      password = args['password'] as String;

    } else {
      print('email is null');
    }

    return Scaffold(
      body:  Container(
        height: double.infinity,
        decoration: BoxDecoration(
            color:AppColor.backgroundColor
        ),

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
                              "Let's Complete Account Details",
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

                                Center(
                                  child: SizedBox(
                                    height: 115,
                                    width: 115,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      fit: StackFit.expand,
                                      children: [
                                        image != null
                                            ? ClipOval(
                                          child: Image.file(
                                            image!,
                                            fit: BoxFit.cover,
                                            height: 115,
                                            width: 115,
                                          ),
                                        )
                                            : CircleAvatar(
                                          backgroundColor: AppColor.primaryColor,
                                          backgroundImage: const NetworkImage(
                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThPleUmSbmYVQSLFMj_D_ZO92sUU8j8r-InYzrQlQgCcaoI-3iHrM2X1Pi3cnMU0__1Bg&usqp=CAU'),
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            right: -25,
                                            child: RawMaterialButton(
                                              onPressed: () {
                                                setState(() {
                                                  _pickImage();
                                                });
                                              },
                                              elevation: 2.0,
                                              fillColor: const Color(0xFFF5F6F9),
                                              padding: const EdgeInsets.all(10.0),
                                              shape: const CircleBorder(),
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                color: AppColor.primaryColor,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30,),
                                CustomTextField(
                                  controller: taglineController,
                                  inputType: TextInputType.text,
                                  hintText: 'Tagline',
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  controller: descriptionController,
                                  inputType: TextInputType.text,
                                  hintText: 'Description',
                                  maxLine: 5,
                                ),

                                const SizedBox(height: 30),
                                button(
                                  width: 200,
                                  text: 'Sign Up',
                                  onPress: () async {
                                    if (taglineController.text.isEmpty) {
                                      Utils.flushBarMessage(
                                          'Tagline field is required', context);
                                    } else if (descriptionController.text.isEmpty) {
                                      Utils.flushBarMessage(
                                          'Description field is required', context);
                                    }  else {
                                      String tagLine= taglineController.text;
                                      String description= descriptionController.text;
                                      print('Name : $name!');
                                      print('Name : $email!');
                                      print('Name : $password!');
                                      await apiServices.signupCompany(
                                        name!,
                                        email!,
                                        password!,
                                        image!,
                                        description,
                                        tagLine,
                                        context,
                                      );
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:style_nexus/controller/onboarding_controller.dart';
import 'package:style_nexus/utils/widget/button.dart';

import '../Services/api_services.dart';
import '../utils/routes/routes_names.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    final controller= Get.put(OnBoardingController());
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(image: 'assets/onBoarding_1.png', title: 'Discover Fashion in AR With StyleNexus', subTitle: 'Virtually try on each piece from the comfort of your home' ,),
              OnBoardingPage(image: 'assets/onBoarding_2.png', title: 'Perfect Fit Every Time', subTitle: 'Recieve personalized size recommendations for guaranteed satisfactions' ,),
              OnBoardingPage(image: 'assets/onBoarding_3.png', title: 'Contribute To \nSustainable Fashion', subTitle: 'Fewer return less waste.\nSave cost and protect our planet' ,),
            ],
          ),

          const OnBoardingDotNavigation(),

          const OnBoardingStartButton()
        ],
      ),
    );
  }
}

class OnBoardingStartButton extends StatelessWidget {
  const OnBoardingStartButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
        right: 20,
        child: button(width: 150, text: 'Get Started', onPress: ()async{
          final apiService = ApiService();
          await apiService.markOnboardingCompleted();
          Navigator.pushReplacementNamed(context, RoutesName.selectionScreen);
        }));
  }
}

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Positioned(
      bottom: 50,
        left: 20,

        child: SmoothPageIndicator(controller: controller.pageController,
          count: 3,
          effect: const ExpandingDotsEffect(activeDotColor: Colors.blue, dotHeight: 6),));
  }
}

class OnBoardingPage extends StatelessWidget {
  final String image, title, subTitle;

  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          child: Image.asset('assets/ellipse.png'),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Use end to push content to the bottom
          children: [
            Center(child: Image.asset(image)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subTitle,
                    style: const TextStyle(color: Colors.grey,
                        fontSize: 22,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
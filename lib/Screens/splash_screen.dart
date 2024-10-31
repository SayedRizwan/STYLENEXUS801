import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_nexus/utils/routes/routes_names.dart';

import '../Services/api_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  Future<String?> _getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('login_type');
  }

  void _navigateToNextScreen() async {
    final apiService = ApiService();
    final hasCompletedOnboarding = await apiService.hasCompletedOnboarding();
    final isLoggedIn = await apiService.isLoggedIn();
    final loginType = await _getLoginType();

    if (!hasCompletedOnboarding) {
      Navigator.pushReplacementNamed(context, RoutesName.onBoardingScreen);
    } else if (isLoggedIn) {
      if (loginType == 'user') {
        Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
      } else if (loginType == 'company') {
        Navigator.pushReplacementNamed(context, RoutesName.companyHomeScreen);
      }
    } else {
      Navigator.pushReplacementNamed(context, RoutesName.selectionScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(right: 0, child: Image.asset('assets/ellipse.png')),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 300,
                    width: 300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

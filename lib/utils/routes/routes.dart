import 'package:flutter/material.dart';
import 'package:style_nexus/Screens/CompanyScreens/company_registration_detail_screen.dart';

import 'package:style_nexus/Screens/CompanyScreens/company_login_screen.dart';
import 'package:style_nexus/Screens/3d_model_screen.dart';
import 'package:style_nexus/Screens/UserScreens/home_screen.dart';
import 'package:style_nexus/Screens/UserScreens/product_screen.dart';
import 'package:style_nexus/Screens/CompanyScreens/subscription_request_screen.dart';
import 'package:style_nexus/Screens/CompanyScreens/subscription_screen.dart';
import 'package:style_nexus/Screens/selectionScreen.dart';

import 'package:style_nexus/Screens/UserScreens/user_login_screen.dart';
import 'package:style_nexus/Screens/UserScreens/user_registration_screen.dart';
import 'package:style_nexus/Screens/splash_screen.dart';
import 'package:style_nexus/Screens/update_password_screen.dart';
import 'package:style_nexus/utils/routes/routes_names.dart';

import '../../Screens/CompanyScreens/comapny_registration_screen.dart';
import '../../Screens/CompanyScreens/company_home_screen.dart';
import '../../Screens/contact_us_screen.dart';
import '../../Screens/on_boarding_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());

      case RoutesName.onBoardingScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const OnBoardingScreen());

      case RoutesName.selectionScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SelectionScreen());

      case RoutesName.userLoginScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const UserLoginScreen());

      case RoutesName.companyLoginScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const CompanyLoginScreen());

      case RoutesName.companyRegistrationScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const CompanyRegistrationScreen());

      case RoutesName.companyRegistrationDetailScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) =>
                const CompanyRegistrationDetailScreen(),
            settings: settings);

      case RoutesName.userRegistrationScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const UserRegistrationScreen());

      case RoutesName.companyHomeScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const CompanyHomeScreen());

      case RoutesName.homeScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen());

      case RoutesName.subscriptionScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SubscriptionScreen());

      case RoutesName.subscriptionRequestScreen:
        final planType = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (BuildContext context) => SubscriptionRequestScreen(planType: planType ?? 'Default Plan'),
        );

      case RoutesName.contactUsScreen:
        final args = settings.arguments as Map<String, dynamic>?; // Nullable Map
        final String? isCompany = args?['isCompany'] as String?;  // Safely extract the string

        return MaterialPageRoute(
          builder: (BuildContext context) => ContactUsScreen(isCompany: isCompany),
        );




      case RoutesName.productScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (BuildContext context) => ProductScreen(
            companyId: args['companyId'] as String,
            imagePath: args['imagePath'] as String,
            companyName: args['companyName'] as String,
          ),
        );

      case RoutesName.modelScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (BuildContext context) => ModelScreen(
                  productName: args['productName'] as String,
                  path: args['path'] as String,
                  isCompany: args['isCompany'] as bool,
                  companyName: args['companyName'] as String,

            ));

      case RoutesName.updatePasswordScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const UpdatePasswordScreen());

      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
                  body: Center(
                    child: Text('No route defined'),
                  ),
                ));
    }
  }
}

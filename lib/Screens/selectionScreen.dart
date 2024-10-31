import 'package:flutter/material.dart';

import '../utils/routes/routes_names.dart';
import '../utils/widget/button.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(right: 0,child: Image.asset('assets/ellipse.png')),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 250,width: 250,),

                  const SizedBox(height: 30,),

                  button(width: 230, text: 'Continue as User', onPress: (){
                    Navigator.pushNamed(context, RoutesName.userLoginScreen);
                  }),
                  const SizedBox(height: 20,),

                  button(width: 230, text: 'Continue as Company', onPress: (){
                    Navigator.pushNamed(context, RoutesName.companyLoginScreen);
                  }),

              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

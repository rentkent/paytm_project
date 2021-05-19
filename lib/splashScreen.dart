import 'package:flutter/material.dart';
import 'package:paytm_project/home.dart';

import 'package:splashscreen/splashscreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      title: Text(
        'Payment Gateway',
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.height * 0.03,
          fontWeight: FontWeight.w700,
          color: Colors.pink[900],
        ),
      ),
      seconds: 2,
      navigateAfterSeconds: MyHomePage(
        title: "Payment Gateway",
      ),
      backgroundColor: Colors.white,
      useLoader: true,
      loaderColor: Colors.pink[900],
    );
  }
}

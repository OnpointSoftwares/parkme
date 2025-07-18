import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'landingScreen.dart';
import 'package:parkme/UserDashboard/dashboard.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(Duration(seconds: 3)); // 3 second delay
    
    // Check if user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // User is logged in, go to Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Dashboard(user: user),
        ),
      );
    } else {
      // User is not logged in, go to Landing Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LandingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/parkmeLogo.png",
              width: 100.0,
              height: 100.0,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kprimaryColor),
            ),
            SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
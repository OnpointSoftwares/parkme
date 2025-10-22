import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'landingScreen.dart';
import 'package:parkme/UserDashboard/dashboard.dart';
import 'package:parkme/admin/admin_dashboard.dart';
import 'package:parkme/owner/owner_dashboard_main.dart';
import '../utils/app_theme.dart';

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
      // User is logged in, check their role
      try {
        final db = FirebaseDatabase.instance;
        final snapshot = await db.ref('users/${user.uid}/role').get();
        
        final role = snapshot.exists ? snapshot.value as String? : null;
        
        if (!mounted) return;
        
        Widget destination;
        switch (role) {
          case 'admin':
            destination = AdminDashboardPage();
            break;
          case 'owner':
            destination = const OwnerDashboard();
            break;
          default:
            destination = Dashboard(user: user);
        }
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destination),
        );
      } catch (e) {
        // If error fetching role, default to regular dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Dashboard(user: user),
            ),
          );
        }
      }
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
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTheme.logo(size: 120),
            SizedBox(height: 32),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'PARK',
                    style: AppTheme.headingStyle.copyWith(fontSize: 36),
                  ),
                  TextSpan(
                    text: 'ING',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 36,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:parkme/Authentication/signIn.dart';
import 'package:parkme/Authentication/signUp.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/app_theme.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 60),
              
              // Logo and Title
              Center(child: AppTheme.logo(size: 100)),
              SizedBox(height: 24),
              
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'PARK',
                      style: AppTheme.headingStyle.copyWith(fontSize: 32),
                    ),
                    TextSpan(
                      text: 'ING',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 32,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              Text(
                "Your parking partner",
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              
              SizedBox(height: 40),
              // Features
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildFeatureCard(
                      icon: Icons.search,
                      title: "Find Parking",
                      description: "Locate available parking spots near you",
                    ),
                    SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.qr_code_scanner,
                      title: "Quick Check-in",
                      description: "Scan QR code for instant access",
                    ),
                    SizedBox(height: 16),
                    _buildFeatureCard(
                      icon: Icons.payment,
                      title: "Easy Payment",
                      description: "Pay securely with M-Pesa",
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 60),
              // Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUp()),
                          );
                        },
                        style: AppTheme.primaryButtonStyle,
                        child: Text('GET STARTED', style: AppTheme.buttonTextStyle),
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        )
                      ],
                    ),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  static Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryYellow,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

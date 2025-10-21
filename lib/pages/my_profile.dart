import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/Authentication/signIn.dart';
import 'package:parkme/UserDashboard/ChangePassword.dart';
import 'package:parkme/Booking/mybooking.dart';
import 'package:parkme/pages/faq.dart';
import '../utils/app_theme.dart';

class MyProfile extends StatefulWidget {
  final User? user;
  const MyProfile({Key? key, this.user}) : super(key: key);
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final displayName = widget.user?.displayName ?? 'User';
    final email = widget.user?.email ?? 'No email';
    
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryDark,
                      AppTheme.darkBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Profile(),
                    SizedBox(height: 16),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Account Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Settings',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildMenuCard(
                      icon: Icons.book_outlined,
                      title: 'My Bookings',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MyBooking()),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        if (_auth.currentUser != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangePassword(
                                user: _auth.currentUser!,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FAQPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              
              // Sign Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _signOut().whenComplete(() {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => SignIn()),
                        );
                      });
                    },
                    icon: Icon(Icons.logout),
                    label: Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                'ParkMe v1.0.0',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
              
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  Widget Profile() {
    if (widget.user?.photoURL != null) {
      String photoUrl = widget.user!.photoURL!.replaceFirst("s96", "s400");
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryYellow, width: 3),
          image: DecorationImage(
            image: NetworkImage(photoUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    final displayName = widget.user?.displayName ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3), width: 3),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.textGrey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryYellow,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}


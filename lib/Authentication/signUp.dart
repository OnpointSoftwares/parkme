import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parkme/Authentication/signIn.dart';
import 'package:parkme/UserDashboard/dashboard.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/net/firebase.dart';
import 'package:parkme/net/database.dart';
import 'package:parkme/owner/owner_dashboard.dart';
import '../utils/app_theme.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showPassword = false;
  final TextEditingController _displayName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSuccess=false;
  String _selectedUserType = 'user'; // 'user' or 'owner'
  
  @override
  void dispose() {
    _displayName.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo
                Center(child: AppTheme.logo(size: 80)),
                
                SizedBox(height: 16),
                
                // Title
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'PARK',
                          style: AppTheme.headingStyle.copyWith(fontSize: 28),
                        ),
                        TextSpan(
                          text: 'ING',
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 28,
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 8),
                
                Center(
                  child: Text(
                    "Create your account",
                    style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                  ),
                ),
                
                SizedBox(height: 40),
                // Name field
                _buildTextField(
                  controller: _displayName,
                  label: "Full Name",
                ),
                
                SizedBox(height: 20),
                
                // Email field
                _buildTextField(
                  controller: _emailController,
                  label: "Email Address",
                  keyboardType: TextInputType.emailAddress,
                ),
                
                SizedBox(height: 20),
                
                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textGrey,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ),
                
                SizedBox(height: 24),
                // User Type Selection
                Text(
                  "Account Type",
                  style: AppTheme.labelStyle,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserTypeCard(
                        type: 'user',
                        icon: Icons.directions_car,
                        title: 'User',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildUserTypeCard(
                        type: 'owner',
                        icon: Icons.local_parking,
                        title: 'Owner',
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32),
                
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerAccount,
                    style: AppTheme.primaryButtonStyle,
                    child: Text('SIGN UP', style: AppTheme.buttonTextStyle),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppTheme.textLight, fontSize: 14),
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
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryYellow,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTheme.inputStyle,
          decoration: AppTheme.inputDecoration(label).copyWith(
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required String type,
    required IconData icon,
    required String title,
  }) {
    final isSelected = _selectedUserType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryYellow.withOpacity(0.2)
              : AppTheme.darkBackground,
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.textGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryYellow : AppTheme.textLight,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryYellow : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _registerAccount() async {
  try {
    final User? user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )).user;

    if (user != null) {
      await user.updateProfile(displayName: _displayName.text);
      userSetup(_displayName.text);
      final user1 = _auth.currentUser;
      
      // Create a new document for the user with uid and role
      final db = FirebaseDatabase.instance;
      await db.ref('users/${user.uid}').set({
        'email': _emailController.text.trim(),
        'name': _displayName.text.trim(),
        'role': _selectedUserType, // Use selected user type
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Navigate based on user type
      if (mounted) {
        Widget destination = _selectedUserType == 'owner'
            ? OwnerDashboardPage()
            : Dashboard(user: user1 as User);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    } else {
      _isSuccess = false;
    }
  } catch (e) {
    // Show error message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _isSuccess = false;
  }
}
}

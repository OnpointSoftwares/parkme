import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parkme/Authentication/signIn.dart';
import 'package:parkme/UserDashboard/dashboard.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/net/firebase.dart';
import 'package:parkme/net/database.dart';
import 'package:parkme/owner/owner_dashboard.dart';

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
      backgroundColor: kprimaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Image.asset("assets/images/parkmeLogo.png"),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                        child: Text(
                      "Create Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                    SizedBox(
                      height: 6,
                    ),
                    Center(
                        child: Text(
                      "Please fill following details to get started!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _displayName,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: kprimaryColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email ID",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: kprimaryColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            this._showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setState(
                                () => this._showPassword = !this._showPassword);
                          },
                        ),
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: kprimaryColor),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    // User Type Selection
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "I am a:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedUserType = 'user';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _selectedUserType == 'user'
                                          ? kprimaryColor.withOpacity(0.1)
                                          : Colors.grey.shade50,
                                      border: Border.all(
                                        color: _selectedUserType == 'user'
                                            ? kprimaryColor
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.directions_car,
                                          size: 40,
                                          color: _selectedUserType == 'user'
                                              ? kprimaryColor
                                              : Colors.grey.shade600,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Car Owner',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedUserType == 'user'
                                                ? kprimaryColor
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Find parking',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedUserType = 'owner';
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _selectedUserType == 'owner'
                                          ? kprimaryColor.withOpacity(0.1)
                                          : Colors.grey.shade50,
                                      border: Border.all(
                                        color: _selectedUserType == 'owner'
                                            ? kprimaryColor
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.local_parking,
                                          size: 40,
                                          color: _selectedUserType == 'owner'
                                              ? kprimaryColor
                                              : Colors.grey.shade600,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Parking Owner',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedUserType == 'owner'
                                                ? kprimaryColor
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'List your space',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          _registerAccount();
                        },
                      
                        child: Ink(
                          decoration: BoxDecoration(
                            color: kprimaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                                minHeight: 50, maxWidth: double.infinity),
                            child: Text(
                              "SIGN UP",
                              style:
                                  TextStyle(color: kBtnTextColor, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have an account? ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()),
                              );
                            },
                            child: Text(
                              "SIGN IN",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kprimaryColor),
                            ),
                          )
                        ],
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
        Widget destination;
        if (_selectedUserType == 'owner') {
          // Import the new modular dashboard
          destination = OwnerDashboardPage();
        } else {
          destination = Dashboard(user: user1 as User);
        }

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

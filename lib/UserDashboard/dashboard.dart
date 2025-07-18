import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/pages/vehicles.dart';
import '../pages/map_view.dart';
import '../pages/my_profile.dart';

import 'package:parkme/admin/admin_dashboard.dart';
import 'package:parkme/owner/owner_dashboard.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard({Key? key, required this.user}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final tabs = [
    MapView(),
    GroupViewPage(),
    MyProfile(
      user: FirebaseAuth.instance.currentUser,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Access',
              onPressed: () async {
                final uid = widget.user.uid;
                try {
                  /*final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                  final data = doc.data();
                  final role = data != null && data.containsKey('role') ? data['role'] : 'user';
                  if (role == 'admin') {*/
                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AdminDashboardPage()),
                    );
                  } /*else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You do not have admin access.')),
                    );
                  }
                }*/ catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to connect to server. Please check your internet connection.')),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.business_center),
              tooltip: 'Owner Access',
              onPressed: () async {
                final uid = widget.user.uid;
                try {
                  /*final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                  final data = doc.data();
                  final role = data != null && data.containsKey('role') ? data['role'] : 'user';
                  if (role == 'owner') {*/
                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OwnerDashboardPage()),
                    );
                  /*} else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You do not have owner access.')),
                    );
                  }*/
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to connect to server. Please check your internet connection.')),
                  );
                }
              },
            ),
          ],
        ),
        body: tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items:  <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Find',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: "My Vehicles",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label:'My Profile',
            ),
          ],
          selectedItemColor: kprimaryColor,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),

    );
  }
}

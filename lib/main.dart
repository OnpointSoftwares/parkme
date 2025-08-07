import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'appLanding/splashscreen.dart';

Future<void> main() async {
   final PaystackPlugin plugin = PaystackPlugin();
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBe3Pi3AmfuPVAJDyJPcizs8m71dNm9_rQ",
        authDomain: "mechanicfinder-d0833.firebaseapp.com",
        databaseURL: "https://mechanicfinder-d0833-default-rtdb.firebaseio.com",
        projectId: "mechanicfinder-d0833",
        storageBucket: "mechanicfinder-d0833.appspot.com",
        messagingSenderId: "768746472634",
        appId: "1:768746472634:web:7dbcc65ed5eb08e90bee83",
        measurementId: "G-95Z68SXLM5"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park ME',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}



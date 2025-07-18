import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/net/database.dart';

class AddVehicle extends StatefulWidget {
  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehicleName = TextEditingController();
  final TextEditingController _vehicleNum = TextEditingController();
  final TextEditingController _ownerName = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _vehicleName.dispose();
    _vehicleNum.dispose();
    _ownerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimaryColor,
        title: Text('Add Vehicle'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              TextFormField(
                controller: _vehicleName,
                enabled: !_isLoading,
                validator: (value) {
                  return value?.isEmpty == true
                      ? "This field must not be empty"
                      : null;
                },
                decoration: InputDecoration(
                  labelText: "Vehicle Name",
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
              SizedBox(height: 20),
              TextFormField(
                controller: _ownerName,
                enabled: !_isLoading,
                validator: (value) {
                  return value?.isEmpty == true
                      ? "This field must not be empty"
                      : null;
                },
                decoration: InputDecoration(
                  labelText: "Owner Name",
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
              SizedBox(height: 20),
              TextFormField(
                controller: _vehicleNum,
                enabled: !_isLoading,
                validator: (value) {
                  return value?.isEmpty == true
                      ? "This field must not be empty"
                      : null;
                },
                decoration: InputDecoration(
                  labelText: "Vehicle Number",
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
              SizedBox(height: 20),
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      await addVehicleToDatabase(
                        _vehicleName.text.trim(),
                        _ownerName.text.trim(),
                        _vehicleNum.text.trim(),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kprimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: kBtnTextColor)
                      : Text(
                          "ADD",
                          style: TextStyle(color: kBtnTextColor, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addVehicleToDatabase(String vehicle, String owner, String number) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      await DatabaseService(uid: user.uid)
          .updateUserData(vehicle, owner, number);
      
      // Success - navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      // Handle error properly
      print("Error adding vehicle: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add vehicle: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/pages/add_vehicles.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constant.dart';

class GroupViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        width: width,
        height: height,
        child: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance
              .ref('vehicles')
              .orderByChild('uid')
              .equalTo(FirebaseAuth.instance.currentUser!.uid)
              .onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(child: AddVehicle());
            }
            
            final vehiclesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            // Convert to list of entries to preserve keys
            final vehicleEntries = vehiclesMap.entries.toList();
            
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          "My Vehicles",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kprimaryColor,
                              fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: width,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddVehicle()),
                          );
                        },
                        label: Text(
                          "Add new vehicle",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kprimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: kprimaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: vehicleEntries.length,
                    itemBuilder: (BuildContext context, int i) {
                      var vehicleEntry = vehicleEntries[i];
                      var vehicleId = vehicleEntry.key.toString(); // This is the Firebase key
                      var vehicle = vehicleEntry.value as Map<dynamic, dynamic>;

                      return Dismissible(
                        key: Key(vehicleId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          padding: EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Vehicle"),
                              content: Text(
                                  "Are you sure you want to delete this vehicle?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      // Delete from Firebase Realtime Database (not Firestore)
                                      await FirebaseDatabase.instance
                                          .ref('vehicles')
                                          .child(vehicleId)
                                          .remove();
                                      Navigator.of(context).pop(true);
                                    } catch (e) {
                                      Navigator.of(context).pop(false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Failed to delete vehicle: ${e.toString()}"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    child: Icon(
                                      Icons.directions_car_rounded,
                                      color: Colors.black38,
                                      size: 60,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            vehicle['title']?.toString() ?? 'Unknown Vehicle',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: kprimaryColor,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, top: 5),
                                          child: Text(vehicle['owner']?.toString() ?? 'Unknown Owner'),
                                        ),
                                        // Add vehicle number display
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, top: 2),
                                          child: Text(
                                            vehicle['vehicleNumber']?.toString() ?? 'No Number',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
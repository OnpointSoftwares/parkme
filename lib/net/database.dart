import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> updateUserData(String title, String owner, String vehicleNumber) async {
    final userVehicleRef = _dbRef.child('vehicles').push(); // auto-generate a key

    await userVehicleRef.set({
      'title': title,
      'owner': owner,
      'vehicleNumber': vehicleNumber,
      'uid': uid,
    });
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:vehicle_list_app/model.dart';

class FirebaseService {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('vehicles');

  Future<String> addVehicle(Vehicle vehicle) async {
    final newVehicleRef = _database.push();
    await newVehicleRef.set(vehicle.toMap());
    return newVehicleRef.key!;
  }

  Stream<List<Vehicle>> getVehiclesStream() {
    return _database.onValue.map((event) {
      final Map<dynamic, dynamic>? values =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (values == null) return [];

      List<Vehicle> vehicles = [];
      values.forEach((key, value) {
        vehicles.add(Vehicle.fromMap(Map<String, dynamic>.from(value), key));
      });
      return vehicles;
    });
  }

  Future<void> updateVehicle(String id, Vehicle vehicle) async {
    await _database.child(id).update(vehicle.toMap());
  }

  Future<void> deleteVehicle(String id) async {
    await _database.child(id).remove();
  }
}

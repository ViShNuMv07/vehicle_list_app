import 'package:flutter/material.dart';
import 'package:vehicle_list_app/model.dart';
import 'package:vehicle_list_app/firebase.dart';

class VehicleListScreen extends StatefulWidget {
  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Color _getVehicleColor(Vehicle vehicle) {
    final currentYear = DateTime.now().year;
    final vehicleAge = currentYear - vehicle.yearOfManufacture;

    if (vehicle.kmPerLiter >= 15 && vehicleAge <= 5) {
      return Colors.green;
    } else if (vehicle.kmPerLiter >= 15) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle List'),
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: _firebaseService.getVehiclesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final vehicles = snapshot.data ?? [];

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Dismissible(
                key: Key(vehicle.id!),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _firebaseService.deleteVehicle(vehicle.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${vehicle.name} deleted')),
                  );
                },
                child: Card(
                  color: _getVehicleColor(vehicle).withOpacity(0.2),
                  child: ListTile(
                    leading: Icon(
                      Icons.directions_car,
                      color: _getVehicleColor(vehicle),
                    ),
                    title: Text(vehicle.name),
                    subtitle: Text(
                      'Efficiency: ${vehicle.kmPerLiter}km/L\n'
                      'Year: ${vehicle.yearOfManufacture}',
                    ),
                    onTap: () => _showEditVehicleDialog(vehicle),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddVehicleDialog() async {
    final nameController = TextEditingController();
    final kmController = TextEditingController();
    final yearController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Vehicle Name'),
            ),
            TextField(
              controller: kmController,
              decoration: InputDecoration(labelText: 'Km per Liter'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: yearController,
              decoration: InputDecoration(labelText: 'Year of Manufacture'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final vehicle = Vehicle(
                name: nameController.text,
                kmPerLiter: double.parse(kmController.text),
                yearOfManufacture: int.parse(yearController.text),
              );
              await _firebaseService.addVehicle(vehicle);
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditVehicleDialog(Vehicle vehicle) async {
    final nameController = TextEditingController(text: vehicle.name);
    final kmController =
        TextEditingController(text: vehicle.kmPerLiter.toString());
    final yearController =
        TextEditingController(text: vehicle.yearOfManufacture.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Vehicle Name'),
            ),
            TextField(
              controller: kmController,
              decoration: InputDecoration(labelText: 'Km per Liter'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: yearController,
              decoration: InputDecoration(labelText: 'Year of Manufacture'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedVehicle = Vehicle(
                id: vehicle.id,
                name: nameController.text,
                kmPerLiter: double.parse(kmController.text),
                yearOfManufacture: int.parse(yearController.text),
              );
              await _firebaseService.updateVehicle(vehicle.id!, updatedVehicle);
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

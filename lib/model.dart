class Vehicle {
  final String? id;
  final String name;
  final double kmPerLiter;
  final int yearOfManufacture;

  Vehicle({
    this.id,
    required this.name,
    required this.kmPerLiter,
    required this.yearOfManufacture,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'kmPerLiter': kmPerLiter,
      'yearOfManufacture': yearOfManufacture,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map, String id) {
    return Vehicle(
      id: id,
      name: map['name'] ?? '',
      kmPerLiter: (map['kmPerLiter'] ?? 0).toDouble(),
      yearOfManufacture: map['yearOfManufacture'] ?? 0,
    );
  }
}

import 'package:hive/hive.dart';

part 'user_vehicle_model.g.dart';

@HiveType(typeId: 0)
class UserVehicle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String brand;

  @HiveField(2)
  final String model;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final double avgConsumption;

  @HiveField(5)
  final int fuelType; 

  @HiveField(6)
  final String? nickname;

  UserVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.avgConsumption,
    required this.fuelType,
    this.nickname,
  });
}

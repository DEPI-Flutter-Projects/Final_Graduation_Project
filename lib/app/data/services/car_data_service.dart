import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/car_model.dart';

class CarDataService extends GetxService {
  final RxList<CarModel> allCars = <CarModel>[].obs;

  Future<CarDataService> init() async {
    await loadCars();
    return this;
  }

  Future<void> loadCars() async {
    try {
      final String response =
          await rootBundle.loadString('assets/egypt_cars.json');
      final List<dynamic> data = json.decode(response);
      allCars.value = data.map((e) => CarModel.fromJson(e)).toList();
      debugPrint('Loaded ${allCars.length} cars from assets.');
    } catch (e) {
      debugPrint('Error loading car data: $e');
    }
  }

  List<String> get uniqueBrands => allCars.map((c) => c.brand).toSet().toList();

  List<CarModel> getModelsByBrand(String brand) {
    return allCars.where((c) => c.brand == brand).toList();
  }
}

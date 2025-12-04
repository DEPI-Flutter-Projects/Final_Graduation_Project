class CarModel {
  final String brand;
  final String model;
  final int yearStart;
  final int yearEnd;
  final double avgConsumption;
  final int fuelTypeRecommendation;

  CarModel({
    required this.brand,
    required this.model,
    required this.yearStart,
    required this.yearEnd,
    required this.avgConsumption,
    required this.fuelTypeRecommendation,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      brand: json['brand'] as String,
      model: json['model'] as String,
      yearStart: json['year_start'] as int,
      yearEnd: json['year_end'] as int,
      avgConsumption: (json['avg_consumption_l_100km'] as num).toDouble(),
      fuelTypeRecommendation: json['fuel_type_recommendation'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'year_start': yearStart,
      'year_end': yearEnd,
      'avg_consumption_l_100km': avgConsumption,
      'fuel_type_recommendation': fuelTypeRecommendation,
    };
  }

  String get displayName => '$brand $model ($yearStart-$yearEnd)';
}

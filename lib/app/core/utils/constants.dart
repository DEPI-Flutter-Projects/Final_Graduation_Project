import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}

class PricingConstants {
  static const double gasoline80 = 17.75;
  static const double gasoline92 = 19.25;
  static const double gasoline95 = 21.00;
  static const double diesel = 17.50;
  static const double naturalGas = 10.00;
  static const double cng = 10.00;

  static const int metroTier1Price = 8;
  static const int metroTier2Price = 10;
  static const int metroTier3Price = 15;
  static const int metroTier4Price = 20;

  static const int metroTier1Limit = 9;
  static const int metroTier2Limit = 16;
  static const int metroTier3Limit = 23;

  static const int microbusCapacity = 14;
  static const double microbusAvgConsumptionNaturalGas = 14.0;
  static const double microbusAvgConsumptionCng = 14.0;
}

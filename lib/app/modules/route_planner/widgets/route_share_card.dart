import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class RouteShareCard extends StatelessWidget {
  final String startLocation;
  final String endLocation;
  final String distance;
  final String duration;
  final String cost;
  final List<LatLng> routePoints;
  final String userName;
  final String? carModel;

  const RouteShareCard({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.distance,
    required this.duration,
    required this.cost,
    required this.routePoints,
    required this.userName,
    this.carModel,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMM d, yyyy').format(now);
    final timeStr = DateFormat('h:mm a').format(now);

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 1080,
        height: 2400, 
        child: Container(
          color: const Color(0xFFF5F7FA), 
          padding: const EdgeInsets.all(60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.directions_car,
                          color: Colors.white, size: 60),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'El-Moshwar',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      'Trip Summary',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    
                    Row(
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle,
                                color: AppColors.success, size: 32),
                            
                            SizedBox(
                              height: 80,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    width: 4,
                                    height: 8,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.location_on,
                                color: AppColors.error, size: 40),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                startLocation,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 40),
                              Text(
                                endLocation,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 40),

                    
                    Table(
                      children: [
                        TableRow(
                          children: [
                            _buildDetailCell('Date', dateStr),
                            _buildDetailCell('Time', timeStr),
                          ],
                        ),
                        const TableRow(children: [
                          SizedBox(height: 40),
                          SizedBox(height: 40)
                        ]),
                        TableRow(
                          children: [
                            _buildDetailCell('Car', carModel ?? 'Unknown'),
                            _buildDetailCell('Cost', cost,
                                valueColor: AppColors.primary),
                          ],
                        ),
                        const TableRow(children: [
                          SizedBox(height: 40),
                          SizedBox(height: 40)
                        ]),
                        TableRow(
                          children: [
                            _buildDetailCell('Duration', duration),
                            _buildDetailCell('Distance', distance),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: _calculateCenter(),
                          initialZoom: _calculateZoom(),
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.elmoshwar',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                strokeWidth: 12,
                                color: AppColors.primary,
                                borderColor: Colors.white,
                                borderStrokeWidth: 4,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: routePoints.first,
                                width: 60,
                                height: 60,
                                child: Transform.rotate(
                                  angle: 45 * (3.14159 / 180), 
                                  child: const Icon(Icons.navigation,
                                      color: AppColors.primary, size: 60),
                                ),
                              ),
                              Marker(
                                point: routePoints.last,
                                width: 60,
                                height: 60,
                                child: const Icon(Icons.location_on,
                                    color: AppColors.error, size: 60),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      Positioned(
                        bottom: 40,
                        right: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.navigation,
                                  color: Colors.white, size: 40),
                              SizedBox(width: 16),
                              Text(
                                'Start',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: 32,
                        left: 32,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCell(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  LatLng _calculateCenter() {
    if (routePoints.isEmpty) return const LatLng(30.0444, 31.2357); 
    double latSum = 0;
    double lngSum = 0;
    for (var p in routePoints) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / routePoints.length, lngSum / routePoints.length);
  }

  double _calculateZoom() {
    
    return 12.5;
  }
}

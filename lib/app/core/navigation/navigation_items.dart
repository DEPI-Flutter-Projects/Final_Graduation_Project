import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final String route;
  final IconData icon;
  NavigationItem(
      {required this.title, required this.route, required this.icon});
}

final navigationItems = <NavigationItem>[
  NavigationItem(title: 'Home', route: '/home', icon: Icons.home),
  NavigationItem(
      title: 'Route Planner', route: '/route_planner', icon: Icons.map),
  NavigationItem(
      title: 'Map View', route: '/map_view', icon: Icons.location_on),
  NavigationItem(
      title: 'Cost Calculator',
      route: '/cost_calculator',
      icon: Icons.calculate),
  NavigationItem(
      title: 'Vehicles', route: '/garage', icon: Icons.directions_car),
  NavigationItem(title: 'Profile', route: '/profile', icon: Icons.person),
  NavigationItem(title: 'Settings', route: '/settings', icon: Icons.settings),
];

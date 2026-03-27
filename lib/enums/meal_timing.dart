import 'package:flutter/material.dart';

enum MealTiming {
  breakfast('朝食', Icons.wb_sunny, '07:00'),
  morningSnack('午前おやつ', Icons.coffee, '10:00'),
  lunch('昼食', Icons.restaurant, '12:00'),
  afternoonSnack('午後おやつ', Icons.cookie, '15:00'),
  preSport('運動前', Icons.bolt, '16:00'),
  postSport('運動後', Icons.battery_charging_full, '18:30'),
  dinner('夕食', Icons.dinner_dining, '19:00'),
  nightSnack('夜食', Icons.nightlight, '21:00');

  const MealTiming(this.label, this.icon, this.defaultTime);
  final String label;
  final IconData icon;
  final String defaultTime;
}

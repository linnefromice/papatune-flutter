import 'package:flutter/material.dart';

enum HouseholdDuty {
  cooking('料理', Icons.restaurant),
  cleaning('掃除', Icons.cleaning_services),
  laundry('洗濯', Icons.local_laundry_service),
  bathTime('お風呂', Icons.bathtub),
  bedtime('寝かしつけ', Icons.bed),
  shopping('買い物', Icons.shopping_cart),
  childPickup('送迎', Icons.directions_car);

  const HouseholdDuty(this.label, this.icon);
  final String label;
  final IconData icon;
}

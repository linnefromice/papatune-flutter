import 'package:flutter/material.dart';

enum PlanMode {
  planA('Plan A', '通常モード', Colors.green),
  planB('Plan B', '睡眠不足モード', Colors.orange),
  planC('Plan C', 'サバイバルモード', Colors.redAccent);

  const PlanMode(this.label, this.description, this.color);
  final String label;
  final String description;
  final Color color;
}

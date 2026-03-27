import 'package:flutter/material.dart';

/// 3つのライフロール
enum LifeRole {
  engineer('エンジニア', Icons.computer, '仕事・キャリア'),
  papa('パパ', Icons.family_restroom, '家族・育児'),
  athlete('アスリート', Icons.sports_soccer, '運動・フットサル');

  const LifeRole(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}

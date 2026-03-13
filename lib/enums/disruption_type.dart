import 'package:flutter/material.dart';

enum DisruptionType {
  nightWaking('夜泣き・夜中起き', Icons.nightlight_round, 20),
  childSick('子供の体調不良', Icons.sick, 30),
  tantrum('癇癪・ぐずり', Icons.sentiment_very_dissatisfied, 10),
  lateBedtime('寝かしつけ遅延', Icons.bedtime, 15),
  overwork('仕事の長引き', Icons.work_history, 15),
  other('その他', Icons.more_horiz, 10);

  const DisruptionType(this.label, this.icon, this.impactScore);
  final String label;
  final IconData icon;
  final int impactScore;
}

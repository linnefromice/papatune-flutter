import 'package:flutter/material.dart';

class TaskTemplateCategory {
  final String label;
  final IconData icon;
  final List<String> tasks;

  const TaskTemplateCategory({
    required this.label,
    required this.icon,
    required this.tasks,
  });
}

class TaskTemplates {
  TaskTemplates._();

  static const categories = <TaskTemplateCategory>[
    TaskTemplateCategory(
      label: '朝の準備',
      icon: Icons.wb_sunny_outlined,
      tasks: ['起床', '朝支度', '朝食準備', '朝食', '歯磨き・身支度', '子どもの着替え', '保育園・学校の準備', '送り出し・送迎'],
    ),
    TaskTemplateCategory(
      label: '仕事',
      icon: Icons.work_outline,
      tasks: ['通勤', '仕事開始', '集中ワーク', 'ミーティング', '午後ワーク', '退勤'],
    ),
    TaskTemplateCategory(
      label: '食事',
      icon: Icons.restaurant_outlined,
      tasks: ['昼食準備', '昼食', '夕食準備', '夕食', '食器洗い'],
    ),
    TaskTemplateCategory(
      label: '家事',
      icon: Icons.home_outlined,
      tasks: ['掃除', '洗濯', '洗濯物たたみ', 'ゴミ出し', '買い物', '片付け', 'アイロンがけ'],
    ),
    TaskTemplateCategory(
      label: '育児',
      icon: Icons.child_care_outlined,
      tasks: ['お迎え', 'おむつ替え', 'ミルク・授乳', '子どもと遊ぶ', '宿題サポート', '寝かしつけ', '子どもの入浴'],
    ),
    TaskTemplateCategory(
      label: '自分の時間',
      icon: Icons.self_improvement_outlined,
      tasks: ['仮眠', '風呂', '読書', '運動・ストレッチ', 'リラックスタイム', '趣味'],
    ),
    TaskTemplateCategory(
      label: 'その他',
      icon: Icons.more_horiz,
      tasks: ['通院', '役所手続き', '習い事送迎', '日用品の補充', '連絡・事務処理'],
    ),
  ];

  static const weekdayDefaults = [
    '朝支度',
    '朝食',
    '送り出し・送迎',
    '仕事開始',
    '昼食',
    '仮眠',
    'お迎え',
    '夕食準備',
    '夕食',
    '風呂',
    '寝かしつけ',
    '読書',
  ];

  static const weekendDefaults = [
    '朝支度',
    '朝食',
    '子どもと遊ぶ',
    '昼食',
    '仮眠',
    '買い物',
    '夕食準備',
    '夕食',
    '風呂',
    '読書',
  ];
}

enum WorkStyle {
  remote('リモートワーク'),
  office('オフィス勤務'),
  hybrid('ハイブリッド'),
  freelance('フリーランス');

  const WorkStyle(this.label);
  final String label;
}

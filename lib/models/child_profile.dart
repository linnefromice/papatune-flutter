class ChildProfile {
  final String name;
  final DateTime birthDate;

  ChildProfile({required this.name, required this.birthDate});

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get ageLabel => '$ageInYears歳';

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthDate': birthDate.toIso8601String(),
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        name: json['name'] as String,
        birthDate: DateTime.parse(json['birthDate'] as String),
      );
}

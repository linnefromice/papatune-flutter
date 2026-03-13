import '../enums/household_duty.dart';
import '../enums/plan_mode.dart';
import '../models/dad_profile.dart';
import '../models/daily_plan.dart';
import '../models/plan_task.dart';

class PlanGenerator {
  DailyPlan generate(DadProfile profile, PlanMode mode, DateTime date) {
    final isSportDay = profile.sportDaysOfWeek.contains(date.weekday);

    final tasks = switch (mode) {
      PlanMode.planA => _planATasks(profile, isSportDay),
      PlanMode.planB => _planBTasks(profile, isSportDay),
      PlanMode.planC => _planCTasks(profile),
    };

    return DailyPlan(date: date, mode: mode, tasks: tasks);
  }

  List<PlanTask> _planATasks(DadProfile profile, bool isSportDay) {
    final tasks = <PlanTask>[
      PlanTask(title: '朝のストレッチ (10分)', timeSlot: '06:30'),
      PlanTask(title: '朝食 & 子供の準備', timeSlot: '07:00'),
      ..._workTasks(profile, fullMode: true),
      ..._exerciseTasks(isSportDay, fullMode: true),
      ..._dutyTasks(profile.duties),
      PlanTask(
          title: '自分の時間 (読書・リラックス)',
          timeSlot: '21:30',
          isOptional: true),
      PlanTask(title: '就寝', timeSlot: '23:00'),
    ];
    tasks.sort((a, b) => (a.timeSlot ?? '').compareTo(b.timeSlot ?? ''));
    return tasks;
  }

  List<PlanTask> _planBTasks(DadProfile profile, bool isSportDay) {
    final tasks = <PlanTask>[
      PlanTask(title: '軽いストレッチ (5分)', timeSlot: '07:00'),
      PlanTask(title: '朝食 & 子供の準備', timeSlot: '07:15'),
      ..._workTasks(profile, fullMode: false),
      ..._exerciseTasks(isSportDay, fullMode: false),
      ..._dutyTasks(profile.duties),
      PlanTask(title: '早めの就寝', timeSlot: '22:00'),
    ];
    tasks.sort((a, b) => (a.timeSlot ?? '').compareTo(b.timeSlot ?? ''));
    return tasks;
  }

  List<PlanTask> _planCTasks(DadProfile profile) {
    final tasks = <PlanTask>[
      PlanTask(title: '起きる → 最低限の準備', timeSlot: '07:00'),
      PlanTask(title: '子供のケア（最優先）', timeSlot: '08:00'),
      if (profile.isRemoteWork)
        PlanTask(title: '最低限の仕事のみ', timeSlot: '09:00'),
      PlanTask(title: '炭水化物多めの食事でエネルギー補給', timeSlot: '12:00'),
      if (profile.duties.contains(HouseholdDuty.cooking))
        PlanTask(title: '食事は簡単なもので OK', timeSlot: '18:00'),
      PlanTask(title: '全員早めに就寝', timeSlot: '21:00'),
    ];
    return tasks;
  }

  List<PlanTask> _workTasks(DadProfile profile, {required bool fullMode}) {
    if (profile.isRemoteWork) {
      return [
        PlanTask(
            title: fullMode ? '集中ワークタイム' : 'ワークタイム（ペースダウン可）',
            timeSlot: '09:00'),
        PlanTask(
            title: fullMode ? '昼食 & 仮眠 (15分)' : '昼食 & 仮眠 (20分推奨)',
            timeSlot: '12:00'),
        PlanTask(
            title: fullMode ? '午後ワークタイム' : '午後ワーク（必須タスクのみ）',
            timeSlot: '13:00'),
      ];
    }
    return [
      PlanTask(
          title: fullMode ? '通勤 & 仕事' : '通勤 & 仕事（必須タスク優先）',
          timeSlot: '08:30'),
      if (fullMode) PlanTask(title: '昼食', timeSlot: '12:00'),
    ];
  }

  List<PlanTask> _exerciseTasks(bool isSportDay, {required bool fullMode}) {
    if (isSportDay) {
      if (fullMode) {
        return [
          PlanTask(title: 'スポーツの準備・移動', timeSlot: '16:00'),
          PlanTask(title: 'スポーツ', timeSlot: '17:00'),
        ];
      }
      return [
        PlanTask(
            title: 'スポーツは軽めに（無理しない）',
            timeSlot: '17:00',
            isOptional: true),
      ];
    }
    if (fullMode) {
      return [
        PlanTask(
            title: '自重トレーニング (20分)', timeSlot: '17:30', isOptional: true),
      ];
    }
    return [
      PlanTask(
          title: 'お風呂でリカバリーストレッチ (3分)',
          timeSlot: '18:30',
          isOptional: true),
    ];
  }

  static const _dutyTaskMap = {
    HouseholdDuty.cooking: ('夕食の準備', '17:30', false),
    HouseholdDuty.bathTime: ('お風呂タイム', '19:00', false),
    HouseholdDuty.bedtime: ('寝かしつけ', '20:00', false),
    HouseholdDuty.cleaning: ('片付け', '20:30', true),
    HouseholdDuty.laundry: ('洗濯', '21:00', true),
    HouseholdDuty.shopping: ('買い物（必要なら）', '16:00', true),
    HouseholdDuty.childPickup: ('子供の送迎', '15:30', false),
  };

  List<PlanTask> _dutyTasks(Set<HouseholdDuty> duties) {
    return duties.map((duty) {
      final (title, timeSlot, isOptional) = _dutyTaskMap[duty]!;
      return PlanTask(title: title, timeSlot: timeSlot, isOptional: isOptional);
    }).toList();
  }
}

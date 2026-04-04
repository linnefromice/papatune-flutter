import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/daily_plan.dart';
import '../../../providers/plan_provider.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planProvider = context.watch<PlanProvider>();
    final selectedPlan = planProvider.getPlanForDate(_selectedDay);
    final plans = planProvider.plans;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('記録', style: theme.textTheme.headlineMedium),
          ),
          TableCalendar<DailyPlan>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) {
              final plan = plans[_dateKey(day)];
              return plan != null ? [plan] : [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerSize: 6,
              markersMaxCount: 1,
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonShowsNext: false,
              titleCentered: true,
            ),
            locale: 'ja_JP',
            startingDayOfWeek: StartingDayOfWeek.monday,
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedPlan != null
                ? _DayPlanDetail(
                    plan: selectedPlan,
                    date: _selectedDay,
                  )
                : Center(
                    child: Text(
                      '${DateFormat('M/d (E)', 'ja_JP').format(_selectedDay)} の記録はありません',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _dateKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }
}

class _DayPlanDetail extends StatelessWidget {
  final DailyPlan plan;
  final DateTime date;

  const _DayPlanDetail({required this.plan, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('M/d (E)', 'ja_JP').format(date);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(dateLabel, style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: plan.mode.color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                plan.mode.description,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: plan.mode.color,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${plan.completedCount} / ${plan.totalCount}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value:
              plan.totalCount > 0 ? plan.completedCount / plan.totalCount : 0,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 12),
        ...plan.tasks.map((task) {
          return ListTile(
            dense: true,
            leading: Checkbox(
              value: task.isDone,
              onChanged: (_) {
                context
                    .read<PlanProvider>()
                    .toggleTaskForDate(date, task.id);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
            subtitle: task.timeSlot != null ? Text(task.timeSlot!) : null,
            trailing: task.isOptional
                ? Chip(
                    label: const Text('任意'),
                    labelStyle: theme.textTheme.labelSmall,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          );
        }),
      ],
    );
  }
}

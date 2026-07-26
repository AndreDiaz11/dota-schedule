import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final Set<DateTime> daysWithMatches;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const MonthCalendar({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.daysWithMatches,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  static const _weekdayLabels = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = month.weekday % 7;
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevMonth),
              Text(
                _capitalize(DateFormat('MMMM yyyy', 'es').format(month)),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNextMonth),
            ],
          ),
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++) _buildCell(row * 7 + col, firstWeekday, daysInMonth),
              ],
            ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Widget _buildCell(int index, int firstWeekday, int daysInMonth) {
    final dayNum = index - firstWeekday + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const Expanded(child: SizedBox(height: 44));
    }
    final day = DateTime(month.year, month.month, dayNum);
    final isSelected = day == selectedDay;
    final hasMatches = daysWithMatches.contains(day);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onSelectDay(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  if (hasMatches)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.accentOnDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

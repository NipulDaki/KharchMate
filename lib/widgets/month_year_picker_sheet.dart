import 'package:flutter/material.dart';
import 'package:kharch_mate/resources/app_colors.dart';

class MonthYearResult {
  final DateTime? date;
  final bool isAllMonths;

  const MonthYearResult.month(DateTime d)
      : date = d,
        isAllMonths = false;

  const MonthYearResult.allMonths()
      : date = null,
        isAllMonths = true;
}

Future<MonthYearResult?> showMonthYearPickerSheet({
  required BuildContext context,
  required DateTime initialDate,
  bool allowAllMonths = false,
  bool isAllMonths = false,
  int? minYear,
  int? maxYear,
}) {
  return showModalBottomSheet<MonthYearResult>(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => MonthYearPickerSheet(
      initialDate: initialDate,
      allowAllMonths: allowAllMonths,
      isAllMonths: isAllMonths,
      minYear: minYear,
      maxYear: maxYear,
    ),
  );
}

class MonthYearPickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final bool allowAllMonths;
  final bool isAllMonths;
  final int? minYear;
  final int? maxYear;

  const MonthYearPickerSheet({
    super.key,
    required this.initialDate,
    this.allowAllMonths = false,
    this.isAllMonths = false,
    this.minYear,
    this.maxYear,
  });

  @override
  State<MonthYearPickerSheet> createState() => _MonthYearPickerSheetState();
}

class _MonthYearPickerSheetState extends State<MonthYearPickerSheet> {
  late int _selectedYear;
  late int? _selectedMonth;
  late bool _isAllMonths;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _isAllMonths = widget.isAllMonths;
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.isAllMonths ? null : widget.initialDate.month;
  }

  void _previousYear() {
    if (widget.minYear != null && _selectedYear <= widget.minYear!) return;
    setState(() => _selectedYear--);
  }

  void _nextYear() {
    if (widget.maxYear != null && _selectedYear >= widget.maxYear!) return;
    setState(() => _selectedYear++);
  }

  void _selectMonth(int month) {
    final pickedDate = DateTime(_selectedYear, month, 1);
    Navigator.of(context).pop(MonthYearResult.month(pickedDate));
  }

  void _selectAllMonths() {
    Navigator.of(context).pop(const MonthYearResult.allMonths());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: "Select Month" & (optional) All Months button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Month',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                if (widget.allowAllMonths)
                  TextButton(
                    onPressed: _selectAllMonths,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      backgroundColor: _isAllMonths
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'All Months',
                      style: TextStyle(
                        color: _isAllMonths
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            _isAllMonths ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Year Selector Bar with arrows
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    onPressed: _previousYear,
                    tooltip: 'Previous Year',
                  ),
                  Text(
                    '$_selectedYear',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    onPressed: _nextYear,
                    tooltip: 'Next Year',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 12 Months Grid: 3 columns x 4 rows
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = !_isAllMonths &&
                    _selectedMonth == month &&
                    widget.initialDate.year == _selectedYear;
                final isCurrentMonth =
                    now.year == _selectedYear && now.month == month;

                return InkWell(
                  onTap: () => _selectMonth(month),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isCurrentMonth
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isCurrentMonth
                                ? AppColors.primaryLight
                                : AppColors.borderColor,
                        width: isSelected || isCurrentMonth ? 1.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _months[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : isCurrentMonth
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                            color: isSelected
                                ? AppColors.white
                                : isCurrentMonth
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        if (isCurrentMonth && !isSelected)
                          const Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

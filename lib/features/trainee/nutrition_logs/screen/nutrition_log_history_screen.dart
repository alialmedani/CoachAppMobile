import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_log_cubit.dart';
import '../data/model/nutrition_log_model.dart';
import 'nutrition_log_view_screen.dart';

/// Paged history of the trainee's own nutrition logs (newest first). Rows are
/// headers (date + notes); tapping opens the shared view/edit/delete detail.
/// A date-range filter narrows the query and refetches the list.
///
/// Requires a [NutritionLogCubit] provided by the caller.
class NutritionLogHistoryScreen extends StatefulWidget {
  const NutritionLogHistoryScreen({super.key});

  @override
  State<NutritionLogHistoryScreen> createState() =>
      _NutritionLogHistoryScreenState();
}

class _NutritionLogHistoryScreenState extends State<NutritionLogHistoryScreen> {
  PaginationCubit? _pagination;
  DateTime? _from;
  DateTime? _to;

  static String _fmt(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  void _refresh() => _pagination?.getList();

  Future<void> _pickFrom(NutritionLogCubit cubit) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _to ?? DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _from = picked);
    cubit.setHistoryFrom(_fmt(picked));
    _refresh();
  }

  Future<void> _pickTo(NutritionLogCubit cubit) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: _from ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _to = picked);
    cubit.setHistoryTo(_fmt(picked));
    _refresh();
  }

  void _clearDates(NutritionLogCubit cubit) {
    setState(() {
      _from = null;
      _to = null;
    });
    cubit.setHistoryFrom(null);
    cubit.setHistoryTo(null);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionLogCubit>();
    final hasFilter = _from != null || _to != null;
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'nutrition_history'.tr()),
      body: Column(
        children: [
          Container(
            color: AppDesignSystem.surfaceWhite,
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DateFilterChip(
                    icon: Icons.event_outlined,
                    label: _from == null ? 'from_date'.tr() : _fmt(_from!),
                    isSet: _from != null,
                    onTap: () => _pickFrom(cubit),
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: _DateFilterChip(
                    icon: Icons.event_outlined,
                    label: _to == null ? 'to_date'.tr() : _fmt(_to!),
                    isSet: _to != null,
                    onTap: () => _pickTo(cubit),
                  ),
                ),
                if (hasFilter) ...[
                  SizedBox(width: AppDesignSystem.spacingXS.w),
                  IconButton(
                    tooltip: 'clear_dates'.tr(),
                    icon: Icon(
                      Icons.clear,
                      size: AppDesignSystem.iconSizeSM.sp,
                      color: AppDesignSystem.neutral500,
                    ),
                    onPressed: () => _clearDates(cubit),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: PaginationList<NutritionLogModel>(
              withPagination: true,
              onCubitCreated: (c) => _pagination = c,
              repositoryCallBack: (data) => cubit.fetchNutritionLogList(data),
              noDataWidget: AppEmptyState(
                icon: Icons.restaurant_outlined,
                title: 'no_nutrition_logs'.tr(),
                subtitle: 'no_nutrition_logs_subtitle'.tr(),
                iconColor: AppDesignSystem.primaryColor,
              ),
              listBuilder: (list) => ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingSM.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing4XL.h,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) => _LogRow(
                  date: list[index].date == null ? '' : _fmt(list[index].date!),
                  notes: list[index].notes,
                  onTap: () => _openDetail(cubit, list[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(
    NutritionLogCubit cubit,
    NutritionLogModel log,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionLogViewScreen(logId: log.id ?? ''),
        ),
      ),
    );
    if (changed == true) _refresh();
  }
}

/// Compact date-range button; highlights when a date is set.
class _DateFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSet;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.icon,
    required this.label,
    required this.isSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spacingMD.w,
          vertical: AppDesignSystem.spacingSM.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSet
                ? AppDesignSystem.primaryColor
                : AppDesignSystem.neutral300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          color: isSet
              ? AppDesignSystem.primarySurface
              : AppDesignSystem.surfaceWhite,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppDesignSystem.iconSizeSM.sp,
              color: isSet
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral500,
            ),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: isSet
                      ? AppDesignSystem.primaryDark
                      : AppDesignSystem.neutral600,
                  fontWeight: isSet
                      ? AppDesignSystem.semiBold
                      : AppDesignSystem.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final String date;
  final String? notes;
  final VoidCallback onTap;

  const _LogRow({required this.date, required this.notes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.restaurant,
            color: AppDesignSystem.primaryColor,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.neutral900,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
                if ((notes ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text(
                    notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.neutral500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.neutral400,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
        ],
      ),
    );
  }
}

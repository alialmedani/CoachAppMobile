import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/serving_display.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_log_cubit.dart';
import '../data/model/nutrition_log_model.dart';
import '../data/params/nutrition_log_params.dart';

/// Adjust the trainee's logged food quantities. Macros are server-computed, so
/// this only edits `quantity` (+ preserves foodId/order); saving is a
/// full-replace PUT after which the server returns authoritative totals.
///
/// When [createFromPlan] is set the [log] is an unsaved draft ([NutritionLogModel
/// .draftFromPlan]): saving first POSTs from-plan to create the log and then PUTs
/// the quantities, so backing out without saving leaves no phantom log.
class NutritionLogEditorScreen extends StatefulWidget {
  final NutritionLogModel log;
  final NutritionLogFromPlanParams? createFromPlan;

  const NutritionLogEditorScreen({
    super.key,
    required this.log,
    this.createFromPlan,
  });

  @override
  State<NutritionLogEditorScreen> createState() =>
      _NutritionLogEditorScreenState();
}

class _EntryEditor {
  final NutritionLogEntryModel src;
  final TextEditingController quantity;

  _EntryEditor(this.src)
    : quantity = TextEditingController(text: _trim(src.quantity));

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void dispose() => quantity.dispose();
}

class _NutritionLogEditorScreenState extends State<NutritionLogEditorScreen> {
  late final List<_EntryEditor> _entries;
  late final TextEditingController _notes;
  late final String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _entries = widget.log.entries.map((e) => _EntryEditor(e)).toList();
    _notes = TextEditingController(text: widget.log.notes ?? '');
    _initialSnapshot = _snapshot();
  }

  /// Signature of the current draft (each entry's quantity + notes); the guard
  /// compares it against the snapshot taken after the from-plan pre-fill to know
  /// whether the trainee has changed anything.
  String _snapshot() =>
      [for (final e in _entries) e.quantity.text, _notes.text].join('§');

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  List<NutritionLogEntryModel> _buildEntries() => _entries
      .map(
        (e) => NutritionLogEntryModel(
          foodId: e.src.foodId,
          order: e.src.order,
          quantity: double.tryParse(e.quantity.text.trim()) ?? 0,
          notes: e.src.notes,
        ),
      )
      .toList();

  String? _notesOrNull() =>
      _notes.text.trim().isEmpty ? null : _notes.text.trim();

  UpdateNutritionLogParams _build() {
    return UpdateNutritionLogParams(
      id: widget.log.id ?? '',
      date: (widget.log.date ?? DateTime.now()).toIso8601String(),
      notes: _notesOrNull(),
      entries: _buildEntries(),
    );
  }

  /// Saves the log. For the from-plan draft this creates it (POST from-plan)
  /// then persists quantities (PUT); otherwise it's a plain PUT.
  Future<Result> _submit(NutritionLogCubit cubit) {
    final create = widget.createFromPlan;
    if (create != null) {
      return cubit.logFromPlanThenUpdate(
        nutritionPlanId: create.nutritionPlanId,
        date: create.date,
        entries: _buildEntries(),
        notes: _notesOrNull(),
      );
    }
    return cubit.updateLog(_build());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionLogCubit>();
    return UnsavedChangesGuard(
      isDirty: () => _snapshot() != _initialSnapshot,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(title: 'log_nutrition'.tr()),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingMD.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing4XL.h,
                ),
                children: [
                  for (final e in _entries) ...[
                    _EntryCard(editor: e),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                  ],
                  AppTextField(
                    label: 'notes'.tr(),
                    hint: 'nutrition_log_notes_hint'.tr(),
                    controller: _notes,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            _SaveBar(
              onSubmit: () => _submit(cubit),
              onSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('nutrition_log_saved'.tr()),
                    backgroundColor: AppDesignSystem.successColor,
                  ),
                );
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final _EntryEditor editor;

  const _EntryCard({required this.editor});

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final src = editor.src;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            src.foodName ?? 'meal_item_entry'.tr(),
            style: AppDesignSystem.bodyLarge.copyWith(
              color: AppDesignSystem.neutral900,
              fontWeight: AppDesignSystem.semiBold,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          Wrap(
            spacing: AppDesignSystem.spacingXS.w,
            runSpacing: AppDesignSystem.spacing2XS.h,
            children: [
              AppBadge(
                text: 'macro_calories_kcal'.tr(args: [_n(src.calories)]),
                variant: AppBadgeVariant.warning,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_protein_short_g'.tr(args: [_n(src.proteinG)]),
                variant: AppBadgeVariant.info,
                size: AppBadgeSize.small,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          AppTextField(
            label: 'quantity_servings'.tr(),
            controller: editor.quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          // Live resolved real amount (quantity × servingSize + unit) so the
          // trainee never mistakes a servings count for grams.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: editor.quantity,
            builder: (context, value, _) {
              final q = double.tryParse(value.text.trim()) ?? 0;
              final resolved = ServingDisplay.resolvedAmount(
                q,
                src.servingSize,
                src.servingUnit,
              );
              if (resolved == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: AppDesignSystem.spacingXS.h),
                child: Text(
                  resolved,
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.neutral700,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final Future<Result> Function() onSubmit;
  final VoidCallback onSuccess;

  const _SaveBar({required this.onSubmit, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CreateModel<NutritionLogModel>(
          withValidation: false,
          useCaseCallBack: (_) => onSubmit(),
          onSuccess: (_) => onSuccess(),
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: AppDesignSystem.errorColor,
              ),
            );
          },
          child: Container(
            height: 52.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryColor,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Text(
              'save_log'.tr(),
              style: AppDesignSystem.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: AppDesignSystem.semiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_plan_template_cubit.dart';
import 'widgets/clone_nutrition_template_sheet.dart';
import 'widgets/nutrition_plan_template_card.dart';
import 'nutrition_plan_template_builder_screen.dart';
import 'nutrition_plan_template_detail_screen.dart';

/// Coach nutrition-plan-template library: searchable (debounced), paginated. No
/// active/status filter — templates carry no active state. Create/edit/delete/
/// clone are gated by the coach's granted permissions.
class NutritionPlanTemplatesListScreen extends StatefulWidget {
  /// Drops the top bar so the screen can sit inside the Templates tab's
  /// segmented host (which owns the title); standalone use keeps it.
  final bool embedded;

  const NutritionPlanTemplatesListScreen({super.key, this.embedded = false});

  @override
  State<NutritionPlanTemplatesListScreen> createState() =>
      _NutritionPlanTemplatesListScreenState();
}

class _NutritionPlanTemplatesListScreenState
    extends State<NutritionPlanTemplatesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();
  PaginationCubit? _pagination;

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => _pagination?.getList();

  /// Store the term immediately (keeps the clear button in sync) but debounce
  /// the backend re-fetch so it fires once the user pauses, not per keystroke.
  void _onSearchChanged(NutritionPlanTemplateCubit cubit, String value) {
    cubit.setSearchTerm(value);
    _searchDebouncer.run(() {
      if (mounted) _refresh();
    });
  }

  Future<void> _openCreate(NutritionPlanTemplateCubit cubit) async {
    cubit.prepareCreate();
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const NutritionPlanTemplateBuilderScreen(),
        ),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openDetail(
    NutritionPlanTemplateCubit cubit,
    NutritionPlanModel template,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionPlanTemplateDetailScreen(
            templateId: template.id ?? '',
          ),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _handleAction(
    NutritionPlanTemplateCubit cubit,
    NutritionPlanModel template,
    NutritionPlanTemplateCardAction action,
  ) async {
    switch (action) {
      case NutritionPlanTemplateCardAction.useForTrainee:
        await showCloneNutritionTemplateSheet(
          context,
          cubit: cubit,
          templateId: template.id ?? '',
          templateName: template.name ?? '',
        );
        break;
      case NutritionPlanTemplateCardAction.edit:
        await _openEdit(cubit, template);
        break;
      case NutritionPlanTemplateCardAction.delete:
        await _confirmDelete(cubit, template);
        break;
    }
  }

  /// The list carries only summaries (no meals), so a safe edit must first load
  /// the full template tree before opening the builder — otherwise a PUT would
  /// replace the template with an empty meal list.
  Future<void> _openEdit(
    NutritionPlanTemplateCubit cubit,
    NutritionPlanModel template,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CupertinoActivityIndicator()),
    );
    final result = await cubit.fetchTemplateById(template.id ?? '');
    if (!mounted) return;
    Navigator.pop(context); // dismiss loading
    if (!result.hasDataOnly) {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
      return;
    }
    final full = result.data as NutritionPlanModel;
    if (!mounted) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NutritionPlanTemplateBuilderScreen(template: full),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _confirmDelete(
    NutritionPlanTemplateCubit cubit,
    NutritionPlanModel template,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_template'.tr()),
        content: Text(
          'delete_template_confirm'.tr(args: [template.name ?? '']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppDesignSystem.errorColor,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final result = await cubit.deleteTemplate(template.id ?? '');
    if (!mounted) return;
    if (result.hasDataOnly) {
      _refresh();
      _snack('template_deleted'.tr(), AppDesignSystem.successColor);
    } else {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionPlanTemplateCubit>();
    final session = context.read<SessionCubit>();
    final canCreate = session.can(
      CoachPermissions.nutritionPlanTemplatesCreate,
    );
    final canEdit = session.can(CoachPermissions.nutritionPlanTemplatesUpdate);
    final canDelete = session.can(
      CoachPermissions.nutritionPlanTemplatesDelete,
    );
    final canClone = session.can(CoachPermissions.nutritionPlansCreate);

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: widget.embedded
          ? null
          : AppTopBar(title: 'nutrition_templates'.tr()),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _openCreate(cubit),
              backgroundColor: AppDesignSystem.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text('add_template'.tr()),
            )
          : null,
      body: Column(
        children: [
          BlocBuilder<NutritionPlanTemplateCubit, NutritionPlanTemplateState>(
            builder: (context, state) => Container(
              color: AppDesignSystem.surfaceWhite,
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
              ),
              child: AppTextField(
                hint: 'search_nutrition_templates'.tr(),
                controller: _searchController,
                onChanged: (v) => _onSearchChanged(cubit, v),
                prefixIcon: Icon(
                  Icons.search,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.neutral400,
                ),
                suffixIcon: cubit.searchTerm.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: AppDesignSystem.iconSizeSM.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          cubit.setSearchTerm('');
                          _searchDebouncer.cancel();
                          _refresh();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: PaginationList<NutritionPlanModel>(
              withPagination: true,
              onCubitCreated: (c) => _pagination = c,
              repositoryCallBack: (data) => cubit.fetchTemplateList(data),
              noDataWidget: AppEmptyState(
                icon: Icons.restaurant_menu_outlined,
                title: 'no_nutrition_templates'.tr(),
                subtitle: 'no_nutrition_templates_subtitle'.tr(),
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
                itemBuilder: (context, index) => NutritionPlanTemplateCard(
                  template: list[index],
                  canClone: canClone,
                  canEdit: canEdit,
                  canDelete: canDelete,
                  onTap: () => _openDetail(cubit, list[index]),
                  onAction: (action) =>
                      _handleAction(cubit, list[index], action),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

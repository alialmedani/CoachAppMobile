import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/notes_cubit.dart';
import '../data/model/trainee_note_model.dart';
import 'note_editor_screen.dart';

/// Coach view of a trainee's notes (newest first), with add / edit / delete.
class NotesScreen extends StatefulWidget {
  final String traineeId;
  final String? traineeName;

  const NotesScreen({super.key, required this.traineeId, this.traineeName});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  GetModelCubit? _list;

  void _refresh() => _list?.getModel();

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<void> _openEditor(NotesCubit cubit, {TraineeNoteModel? note}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NoteEditorScreen(note: note),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotesCubit>()..setTrainee(widget.traineeId);
    // F8: only offer "Add" when the coach holds the granular create permission.
    final canCreate =
        context.read<SessionCubit>().can(CoachPermissions.notesCreate);
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'notes'.tr(), subtitle: widget.traineeName),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(cubit),
              backgroundColor: AppDesignSystem.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text('add_note'.tr()),
            )
          : null,
      body: GetModel<List<TraineeNoteModel>>(
        onCubitCreated: (c) => _list = c,
        useCaseCallBack: () => cubit.fetchRecent(),
        modelBuilder: (notes) => notes.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: AppDesignSystem.spacing4XL.h),
                  AppEmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: 'no_notes'.tr(),
                    subtitle: 'no_notes_subtitle'.tr(),
                    iconColor: AppDesignSystem.primaryColor,
                  ),
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingMD.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing4XL.h,
                ),
                itemCount: notes.length,
                itemBuilder: (context, i) => AppCard(
                  margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
                  onTap: () => _openEditor(cubit, note: notes[i]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fmtDate(notes[i].date),
                        style: AppDesignSystem.labelMedium.copyWith(
                          color: AppDesignSystem.neutral500,
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacing2XS.h),
                      Text(
                        notes[i].text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppDesignSystem.bodyMedium.copyWith(
                          color: AppDesignSystem.neutral800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

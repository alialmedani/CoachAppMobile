import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/trainee_cubit.dart';
import '../data/model/trainee_model.dart';
import 'widgets/trainee_profile_form.dart';
import 'widgets/trainee_submit_bar.dart';

/// Edit an existing trainee's profile (login credentials are unchanged here).
class EditTraineeScreen extends StatefulWidget {
  final TraineeModel trainee;

  const EditTraineeScreen({super.key, required this.trainee});

  @override
  State<EditTraineeScreen> createState() => _EditTraineeScreenState();
}

class _EditTraineeScreenState extends State<EditTraineeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<TraineeCubit>().prepareEdit(widget.trainee);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: 'edit_trainee'.tr(),
        subtitle: widget.trainee.fullName,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingMD.h),
              child: Form(
                key: _formKey,
                child: TraineeProfileForm(params: cubit.updateTraineeParams),
              ),
            ),
          ),
          TraineeSubmitBar(
            formKey: _formKey,
            label: 'save_changes'.tr(),
            useCaseCallBack: (_) => cubit.updateTrainee(),
            successMessage: 'trainee_updated'.tr(),
          ),
        ],
      ),
    );
  }
}

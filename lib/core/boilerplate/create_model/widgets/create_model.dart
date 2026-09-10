import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../ui/dialogs/dialogs.dart';
import '../../../utils/Navigation/navigation.dart';
import '../cubits/create_model_cubit.dart';

typedef CreatedCallback = void Function(CreateModelCubit cubit);
typedef ModelCreated<Model> = Function(Model model);

class CreateModel<Model> extends StatefulWidget {
  final ModelCreated<Model>? onSuccess;
  final double? loadingHeight;
  final UsecaseCallBack? useCaseCallBack;
  final CreatedCallback? onCubitCreated;
  final Widget child;
  final Function? onTap;
  final bool withValidation;
  final Function? onError;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const CreateModel({
    super.key,
    this.useCaseCallBack,
    this.onTap,
    this.onCubitCreated,
    required this.child,
    this.onSuccess,
    required this.withValidation,
    this.loadingHeight,
    this.onError,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<CreateModel<Model>> createState() => _GetModelState<Model>();
}

class _GetModelState<Model> extends State<CreateModel<Model>> {
  CreateModelCubit<Model>? cubit;

  @override
  void initState() {
    cubit = CreateModelCubit<Model>(widget.useCaseCallBack!);
    if (widget.onCubitCreated != null) {
      widget.onCubitCreated!(cubit!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateModelCubit, CreateModelState>(
      bloc: cubit,
      builder: (context, state) {
        if (widget.onCubitCreated != null) {
          widget.onCubitCreated!(cubit!);
        }
        if (state is Loading) {
          return widget.loadingWidget ??
              SizedBox(
                height: widget.loadingHeight ?? 50.h,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0),
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              );
        } else {
          return InkWell(
            onTap: () async {
              if (widget.withValidation) {
                var temp = await widget.onTap!();
                if (temp != null && temp == true) {
                  cubit?.createModel();
                }
              } else {
                cubit?.createModel();
              }
            },

            child: widget.child,
          );
        }
      },
      listener: (context, state) {
        if (state is CreateModelSuccessfully) {
          if (widget.onSuccess != null) widget.onSuccess!(state.model);
        }
        if (state is Error) {
          if (widget.errorWidget != null) {
            Navigation.push(widget.errorWidget!);
          } else if (widget.onError != null) {
            widget.onError!(state.message.toString());
          } else {
            Dialogs.showSnackBar(
              message: state.message.toString(),
              typeSnackBar: AnimatedSnackBarType.error,
            );
          }
        }
      },
    );
  }
}

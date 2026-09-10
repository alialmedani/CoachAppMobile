import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coachappmobile/core/ui/widgets/general_error_widget.dart';
import '../../../ui/widgets/loading.dart';
import '../cubits/get_model_cubit.dart';

typedef CreatedCallback = void Function(GetModelCubit cubit);
typedef ModelBuilder<Model> = Widget Function(Model model);
typedef ModelReceived<Model> = Function(Model model);

//////////////////////GetModel////////////////
class GetModel<Model> extends StatefulWidget {
  final double? loadingHeight;
  final Widget? errorWidget;
  final Function? onError;
  final ModelBuilder<Model>? modelBuilder;
  final ModelReceived<Model>? onSuccess;
  final Widget? loadingWidget;
  final double? loadingWidth;
  final UsecaseCallBack? useCaseCallBack;
  final CreatedCallback? onCubitCreated;
  final bool withAnimation;
  final bool withoutCenterLoading;

  const GetModel({
    super.key,
    this.useCaseCallBack,
    this.onCubitCreated,
    this.errorWidget,
    this.modelBuilder,
    this.onSuccess,
    this.loadingHeight,
    this.loadingWidth,
    this.onError,
    this.loadingWidget,
    this.withAnimation = true,
    this.withoutCenterLoading = false,
  });

  @override
  State<GetModel<Model>> createState() => _GetModelState<Model>();
}

class _GetModelState<Model> extends State<GetModel<Model>> {
  GetModelCubit<Model>? cubit;

  @override
  void initState() {
    cubit = GetModelCubit<Model>(widget.useCaseCallBack!);
    if (widget.onCubitCreated != null) {
      widget.onCubitCreated!(cubit!);
    }
    cubit?.getModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetModelCubit, GetModelState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is Loading) {
          return Center(child: widget.loadingWidget ?? LoadingWidget());
        } else {
          if (state is GetModelSuccessfully) {
            return buildModel(state.model);
          } else if (state is Error) {
            return Center(
              child:
                  widget.errorWidget ??
                  GeneralErrorWidget(
                    message: state.message,
                    onTap: () {
                      cubit?.getModel();
                    },
                  ),
            );
          } else {
            return const Text('');
          }
        }
      },
      listener: (context, state) {
        if (state is Error) {
          if (widget.onError != null) {
            widget.onError!();
          }
        } else if (state is GetModelSuccessfully) {
          if (widget.onSuccess != null) widget.onSuccess!(state.model);
        } else if (state is GetModelSuccessfully) {
          if (widget.onSuccess != null) widget.onSuccess!(state.model);
        }
      },
    );
  }

  RefreshIndicator buildModel(Model model) {
    return RefreshIndicator(
      child: widget.modelBuilder!(model),
      onRefresh: () {
        cubit?.getModel();
        return Future.delayed(const Duration(seconds: 1));
      },
    );
  }
}

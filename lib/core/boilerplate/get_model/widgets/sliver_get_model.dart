import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/app_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ui/widgets/loading.dart';
import '../cubits/get_model_cubit.dart';
import 'get_model.dart' show CreatedCallback;

/// Sliver sibling of [GetModel] — a single-model loader whose header scrolls
/// away with its content.
///
/// Composes as a [CustomScrollView]: the [headerSlivers] (an [AppSliverTopBar]
/// plus any sub-header) sit at the top and scroll off, and the loaded model is
/// rendered below them in every state (loading / error / success), so the app
/// bar is never pinned. [modelBuilder] returns an ordinary **box** widget
/// (typically a `Column`, since the enclosing scroll view already scrolls) — it
/// is wrapped in a padded [SliverToBoxAdapter]. Pull-to-refresh re-runs the
/// use case.
class SliverGetModel<Model> extends StatefulWidget {
  final UsecaseCallBack useCaseCallBack;
  final CreatedCallback? onCubitCreated;

  /// Builds the loaded content as a box widget (e.g. a `Column`). It scrolls
  /// inside the shared [CustomScrollView], so it must NOT be independently
  /// scrollable (use `Column`, not `ListView`).
  final Widget Function(Model model) modelBuilder;

  /// Slivers pinned to the TOP of the scroll body (they scroll away) — the
  /// [AppSliverTopBar] and any sub-header.
  final List<Widget> headerSlivers;

  final Widget? loadingWidget;
  final Widget? errorWidget;
  final void Function(Model model)? onSuccess;
  final VoidCallback? onError;

  /// Padding around the loaded content (not the header).
  final EdgeInsetsGeometry? contentPadding;

  final bool withRefresh;

  const SliverGetModel({
    super.key,
    required this.useCaseCallBack,
    required this.modelBuilder,
    this.onCubitCreated,
    this.headerSlivers = const [],
    this.loadingWidget,
    this.errorWidget,
    this.onSuccess,
    this.onError,
    this.contentPadding,
    this.withRefresh = true,
  });

  @override
  State<SliverGetModel<Model>> createState() => _SliverGetModelState<Model>();
}

class _SliverGetModelState<Model> extends State<SliverGetModel<Model>> {
  late final GetModelCubit<Model> _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetModelCubit<Model>(widget.useCaseCallBack);
    widget.onCubitCreated?.call(_cubit);
    _cubit.getModel();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _refresh() => _cubit.getModel();

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        ...widget.headerSlivers,
        BlocConsumer<GetModelCubit<Model>, GetModelState>(
          bloc: _cubit,
          listener: (context, state) {
            if (state is Error) {
              widget.onError?.call();
            } else if (state is GetModelSuccessfully) {
              widget.onSuccess?.call(state.model as Model);
            }
          },
          builder: (context, state) => _contentSliver(state),
        ),
      ],
    );

    if (!widget.withRefresh) return scrollView;
    return RefreshIndicator(
      onRefresh: _refresh,
      edgeOffset: MediaQuery.of(context).padding.top,
      color: AppDesignSystem.primaryColor,
      backgroundColor: AppDesignSystem.surfaceWhite,
      child: scrollView,
    );
  }

  Widget _contentSliver(GetModelState state) {
    if (state is GetModelSuccessfully) {
      final content = widget.modelBuilder(state.model as Model);
      return SliverToBoxAdapter(
        child: widget.contentPadding != null
            ? Padding(padding: widget.contentPadding!, child: content)
            : content,
      );
    }
    if (state is Error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child:
            widget.errorWidget ??
            AppErrorState(
              message: state.message,
              onRetry: () => _cubit.getModel(),
            ),
      );
    }
    // Loading / initial.
    if (widget.loadingWidget != null) {
      return SliverToBoxAdapter(
        child: widget.contentPadding != null
            ? Padding(
                padding: widget.contentPadding!,
                child: widget.loadingWidget!,
              )
            : widget.loadingWidget!,
      );
    }
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: LoadingWidget()),
    );
  }
}

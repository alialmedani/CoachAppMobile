import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/app_error_state.dart';
import 'package:coachappmobile/core/ui/widgets/skeleton/app_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubits/pagination_cubit.dart';
import 'pagination_list.dart' show CreatedCallback;

typedef SliverItemBuilder<Model> = Widget Function(
  BuildContext context,
  Model item,
  int index,
);

/// The "everything scrolls" list.
///
/// A single [CustomScrollView] whose FIRST slivers are the screen's header
/// ([headerSlivers] — typically an [AppSliverTopBar] plus any search / filter /
/// segmented controls) and whose remaining space is a paginated list driven by
/// a [PaginationCubit]. Because the header is part of the same scroll view it
/// **scrolls away with the content** (the app-wide no-pinned-app-bar rule),
/// while still being present in every state — loading, empty, and error — so the
/// search box never vanishes on an empty result.
///
/// This is the sliver sibling of [PaginationList]: same cubit, same
/// [repositoryCallBack]/[onCubitCreated] contract, same load-more + pull-to-
/// refresh semantics, but composed as slivers instead of a fixed
/// header + `Expanded(list)` column.
class SliverPaginatedList<Model> extends StatefulWidget {
  /// Fetch a page — wired to a cubit method returning `Future<Result<List>>`.
  final RepositoryCallBack repositoryCallBack;

  /// Handed the internal [PaginationCubit] so the screen can refresh it
  /// (e.g. after search/filter changes, create/edit/delete).
  final CreatedCallback? onCubitCreated;

  /// Builds one row from a model.
  final SliverItemBuilder<Model> itemBuilder;

  /// Slivers pinned to the TOP of the scroll body (they scroll away). Put the
  /// [AppSliverTopBar] and any search/filter/segmented header here.
  final List<Widget> headerSlivers;

  /// Shown (centred, below the header) when a successful load returns nothing.
  final Widget? noDataWidget;

  /// Shown (below the header) during the initial load. Defaults to the branded
  /// skeleton list.
  final Widget? loadingWidget;

  /// Turns on next-page loading as the user nears the bottom.
  final bool withPagination;

  /// Turns on pull-to-refresh.
  final bool withRefresh;

  /// Extra work to run after a pull-to-refresh completes.
  final Future<void> Function()? onRefresh;

  /// Padding around the list rows (not the header). Defaults to horizontal
  /// gutter + generous bottom room for a floating action button.
  final EdgeInsetsGeometry? listPadding;

  const SliverPaginatedList({
    super.key,
    required this.repositoryCallBack,
    required this.itemBuilder,
    this.onCubitCreated,
    this.headerSlivers = const [],
    this.noDataWidget,
    this.loadingWidget,
    this.withPagination = true,
    this.withRefresh = true,
    this.onRefresh,
    this.listPadding,
  });

  @override
  State<SliverPaginatedList<Model>> createState() =>
      _SliverPaginatedListState<Model>();
}

class _SliverPaginatedListState<Model>
    extends State<SliverPaginatedList<Model>> {
  late final PaginationCubit<Model> _cubit;
  final ScrollController _controller = ScrollController();
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _cubit = PaginationCubit<Model>(widget.repositoryCallBack);
    widget.onCubitCreated?.call(_cubit);
    _cubit.getList();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.withPagination || _loadingMore) return;
    final state = _cubit.state;
    if (state is! GetListSuccessfully || state.noMoreData) return;
    final pos = _controller.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) {
      setState(() => _loadingMore = true);
      _cubit.getList(loadMore: true);
    }
  }

  Future<void> _refresh() async {
    // Silent: keep the current list on screen so only the pull spinner shows
    // (no skeleton flash), then run any screen-supplied follow-up.
    await _cubit.getList(silent: true);
    await widget.onRefresh?.call();
  }

  void _retryLoadMore() {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    _cubit.getList(loadMore: true);
  }

  EdgeInsetsGeometry get _padding =>
      widget.listPadding ??
      EdgeInsets.fromLTRB(
        AppDesignSystem.spacingMD.w,
        AppDesignSystem.spacingSM.h,
        AppDesignSystem.spacingMD.w,
        AppDesignSystem.spacing4XL.h,
      );

  @override
  Widget build(BuildContext context) {
    final scrollView = BlocConsumer<PaginationCubit<Model>, PaginationState>(
      bloc: _cubit,
      listener: (context, state) {
        // A page settled (or failed) — clear the in-flight flag.
        if (_loadingMore &&
            (state is GetListSuccessfully ||
                state is LoadMoreError ||
                state is Error)) {
          setState(() => _loadingMore = false);
        }
      },
      builder: (context, state) {
        return CustomScrollView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [...widget.headerSlivers, _contentSliver(state)],
        );
      },
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

  Widget _contentSliver(PaginationState state) {
    if (state is Loading || state is PaginationInitial) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: _padding,
          child: widget.loadingWidget ?? AppSkeleton.list(lines: 3),
        ),
      );
    }
    if (state is Error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorState(
          message: state.message,
          onRetry: () => _cubit.getList(),
        ),
      );
    }

    final list = state is GetListSuccessfully
        ? state.list.cast<Model>()
        : state is LoadMoreError
        ? state.list.cast<Model>()
        : const <Never>[];

    if (list.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widget.noDataWidget ?? const SizedBox.shrink(),
      );
    }

    return SliverPadding(
      padding: _padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, i) {
          if (i == list.length) return _footer(state);
          return widget.itemBuilder(context, list[i], i);
        }, childCount: list.length + 1),
      ),
    );
  }

  Widget _footer(PaginationState state) {
    if (_loadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingMD.h),
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }
    if (state is LoadMoreError) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingSM.h),
        child: Center(
          child: TextButton.icon(
            onPressed: _retryLoadMore,
            icon: Icon(Icons.refresh, size: AppDesignSystem.iconSizeSM.sp),
            label: Text('load_more_failed'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: AppDesignSystem.neutral500,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

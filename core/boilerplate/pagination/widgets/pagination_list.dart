import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../constant/app_colors/app_colors.dart';
import '../../../ui/widgets/general_error_widget.dart';
import '../../../ui/widgets/loading.dart';
import '../../../ui/widgets/no_data_screen.dart';
import '../cubits/pagination_cubit.dart';
import 'footer.dart';

typedef CreatedCallback = void Function(PaginationCubit cubit);
typedef ListBuilder<Model> = Widget Function(List<Model> list);

class PaginationList<Model> extends StatefulWidget {
  final RepositoryCallBack? repositoryCallBack;
  final ListBuilder<Model>? listBuilder;
  final CreatedCallback? onCubitCreated;
  final bool? withPagination;
  final bool? withRefresh;
  final bool withEmptyWidget;
  final Map<String, dynamic>? initialParam;
  final VoidCallback? onRefresh;
  final Function()? onLoading;
  final Function()? onSuccess;
  final Axis scrollDirection;
  final Widget? errorWidget;
  final Widget? noDataWidget;
  final Widget? loadingWidget;
  final ScrollController? scrollController;
  final double? loadingWidth;
  final double? loadingHeight;
  final ScrollPhysics? physics;
  final Color? baseColor;
  final Color? highlightColor;

  const PaginationList({
    super.key,
    this.noDataWidget,
    this.onSuccess,
    this.onLoading,
    this.scrollController,
    this.errorWidget,
    this.loadingWidget,
    this.scrollDirection = Axis.vertical,
    this.repositoryCallBack,
    this.listBuilder,
    this.withPagination = false,
    this.onCubitCreated,
    this.initialParam,
    this.withEmptyWidget = true,
    this.onRefresh,
    this.loadingWidth,
    this.loadingHeight,
    this.withRefresh = true,
    this.physics,
    this.baseColor,
    this.highlightColor,
  });

  @override
  PaginationListState<Model> createState() => PaginationListState<Model>();
}

class PaginationListState<Model> extends State<PaginationList<Model>> {
  final RefreshController _refreshController = RefreshController();
  PaginationCubit<Model>? cubit;

  @override
  void initState() {
    cubit = PaginationCubit<Model>(widget.repositoryCallBack!);
    if (widget.onCubitCreated != null) {
      widget.onCubitCreated!(cubit!);
    }
    cubit?.getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildConsumer();
  }

  BlocConsumer<PaginationCubit<Model>, PaginationState> _buildConsumer() {
    return BlocConsumer<PaginationCubit<Model>, PaginationState>(
      bloc: cubit,
      listener: (context, state) {
        if (state is Error) {
        } else if (state is GetListSuccessfully) {
          if (widget.onSuccess != null) widget.onSuccess!();
          if (widget.onRefresh != null) widget.onRefresh!();
          _refreshController.refreshCompleted();

          if (state.noMoreData) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
        }
      },
      builder: (context, state) {
        if (state is Loading) {
          return Center(child: widget.loadingWidget ?? LoadingWidget());
        } else if (state is GetListSuccessfully) {
          return smartRefresher(state.list as List<Model>);
        } else if (state is Error) {
          return widget.errorWidget ??
              GeneralErrorWidget(
                message: state.message,
                onTap: () {
                  cubit?.getList();
                },
              );
        } else {
          return Container();
        }
      },
    );
  }

  SmartRefresher smartRefresher(List<Model> list) {
    Widget child;
    if (list.isEmpty && widget.withEmptyWidget) {
      child = widget.noDataWidget ?? const NoDataScreen();
    } else {
      child = widget.listBuilder!(list);
    }

    return SmartRefresher(
      physics: widget.physics,
      scrollController: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      enablePullDown:
          widget.withRefresh == true && widget.scrollDirection == Axis.vertical,
      enablePullUp: widget.withRefresh == false
          ? false
          : (widget.withPagination ?? widget.scrollDirection == Axis.vertical),
      header: MaterialClassicHeader(backgroundColor: AppColors.primary),
      controller: _refreshController,
      onRefresh: () async {
        cubit?.getList();
        if (widget.onLoading != null) widget.onLoading!();
      },
      onLoading: () async {
        cubit?.getList(loadMore: true);
      },
      footer: customFooter,
      child: child,
    );
  }
}

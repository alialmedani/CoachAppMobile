import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../results/result.dart';
import '../models/get_list_request.dart';
part 'pagination_state.dart';

typedef RepositoryCallBack = Future<Result>? Function(dynamic data);

class PaginationCubit<ListModel> extends Cubit<PaginationState> {
  final RepositoryCallBack getData;

  PaginationCubit(this.getData) : super(PaginationInitial());
  List<ListModel> list = [];
  Map<String, dynamic> params = {};
  int take = 10;
  int skip = 0;

  /// Fetch the first page (or the next page when [loadMore] is true).
  ///
  /// When [silent] is true the current list stays on screen while the refresh
  /// runs: no [Loading] spinner, no scroll reset, and a transient failure is
  /// swallowed instead of tearing the list down. Used for background refreshes
  /// (e.g. an incoming notification) where the user shouldn't see a reload.
  Future<void> getList({bool loadMore = false, bool silent = false}) async {
    if (!loadMore) {
      skip = 0;
      if (!silent) emit(Loading());
    } else {
      skip += take;
    }

    var requestData = GetListRequest(skip: skip, take: take);
    var response = await getData(requestData);

    if (response == null) {
      if (!silent) emit(PaginationInitial());
    } else {
      if (response.hasDataOnly) {
        if (loadMore) {
          list.addAll(response.data);
        } else {
          if (kDebugMode) {
            print("list in paginated is $list");
            print(response.data);
          }
          list = response.data;
        }

        emit(
          GetListSuccessfully(
            list: list.toSet().toList(),
            noMoreData:
                (response.data.toSet().toList() as List<ListModel>).isEmpty &&
                loadMore,
          ),
        );
      } else if (response.hasErrorOnly) {
        // Keep the visible list on a silent refresh — a background blip
        // shouldn't replace what the user is looking at with an error screen.
        if (!silent) {
          if (response.error != null) {
            emit(Error(response.error ?? ''));
          }
          emit(Error('Something went wrong'));
        }
      } else {
        if (!silent) emit(PaginationInitial());
      }
    }
  }

  /// Update a single order in the list without refetching.
  /// This is specifically for MerchantWithOrdersModel lists.
  void updateOrderInList(String orderId, dynamic updatedOrder) {
    if (list.isEmpty) return;

    // Check if this is a MerchantWithOrdersModel list
    if (list.first is! Map &&
        list.first.runtimeType.toString().contains('MerchantWithOrders')) {
      final updatedList = list.map((merchantGroup) {
        // Access the orders list through reflection-like approach
        final dynamic group = merchantGroup;
        final List<dynamic> orders = group.orders as List<dynamic>;

        // Check if this group contains the order
        final orderIndex = orders.indexWhere((order) {
          final dynamic o = order;
          return o.id == orderId;
        });

        if (orderIndex == -1) {
          // Order not in this group, return unchanged
          return group;
        }

        // Update the order in this group
        final newOrders = List<dynamic>.from(orders);
        newOrders[orderIndex] = updatedOrder;

        // Return updated group using copyWith
        return group.copyWith(orders: newOrders);
      }).toList();

      list = updatedList.cast<ListModel>();
      emit(GetListSuccessfully(list: list, noMoreData: false));
    } else {
      // For simple lists, just update the item directly
      final index = list.indexWhere((item) {
        final dynamic i = item;
        try {
          return i.id == orderId;
        } catch (e) {
          return false;
        }
      });

      if (index != -1) {
        list[index] = updatedOrder as ListModel;
        emit(
          GetListSuccessfully(
            list: List<ListModel>.from(list),
            noMoreData: false,
          ),
        );
      }
    }
  }

  /// Update the list with new data and emit state (for optimistic updates)
  void updateList(List<ListModel> newList) {
    list = newList;
    emit(GetListSuccessfully(list: list, noMoreData: false));
  }
}

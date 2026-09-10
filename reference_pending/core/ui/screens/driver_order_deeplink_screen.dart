import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/features/Express/driver/screen/driver_order_actions_screen.dart';
import 'package:coachappmobile/features/Express/driver/screen/my_orders_screen.dart';
import 'package:coachappmobile/features/Express/user/order/cubit/order_cubit.dart';
import 'package:coachappmobile/features/Express/user/order/data/model/order_model.dart';

/// Bridge screen for DRIVER notification deep links.
///
/// A notification only carries an orderId, but [DriverOrderActionsScreen] needs
/// the full [OrderModel]. So we fetch the order by id here (the API only returns
/// orders the driver is assigned to), show a spinner, then [pushReplacement] to
/// the real actions screen. If the fetch fails we fall back to the orders list,
/// so a deep link can never dead-end on a blank screen.
class DriverOrderDeepLinkScreen extends StatefulWidget {
  final String orderId;

  const DriverOrderDeepLinkScreen({super.key, required this.orderId});

  @override
  State<DriverOrderDeepLinkScreen> createState() =>
      _DriverOrderDeepLinkScreenState();
}

class _DriverOrderDeepLinkScreenState extends State<DriverOrderDeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndOpen());
  }

  Future<void> _loadAndOpen() async {
    final Result result =
        await context.read<OrderCubit>().fetchOrderById(widget.orderId);
    if (!mounted) return;

    final data = result.data;
    if (result.hasDataOnly && data is OrderModel) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DriverOrderActionsScreen(assignment: data),
        ),
      );
    } else {
      // Couldn't load the order (no access / network) — don't dead-end.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

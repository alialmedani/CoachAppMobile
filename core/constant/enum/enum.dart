import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
 
enum ReturnStatus {
  /// Return initiated
  initiated,

  /// Package picked up from customer location
  pickedUpFromCustomer,

  /// Package in transit to hub
  inTransitToHub,

  /// Package at hub awaiting return processing
  atHub,

  /// Package in transit to merchant
  inTransitToMerchant,

  /// Package returned to merchant
  returnedToMerchant,

  /// Return cancelled
  cancelled,

  /// Driver handed the parcel to the merchant; awaiting merchant confirmation (QR/bulk)
  awaitingMerchantConfirmation;

  static ReturnStatus? fromInt(int? value) {
    switch (value) {
      case 1:
        return ReturnStatus.initiated;
      case 2:
        return ReturnStatus.pickedUpFromCustomer;
      case 3:
        return ReturnStatus.inTransitToHub;
      case 4:
        return ReturnStatus.atHub;
      case 5:
        return ReturnStatus.inTransitToMerchant;
      case 6:
        return ReturnStatus.returnedToMerchant;
      case 7:
        return ReturnStatus.cancelled;
      case 8:
        return ReturnStatus.awaitingMerchantConfirmation;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ReturnStatus.initiated:
        return 1;
      case ReturnStatus.pickedUpFromCustomer:
        return 2;
      case ReturnStatus.inTransitToHub:
        return 3;
      case ReturnStatus.atHub:
        return 4;
      case ReturnStatus.inTransitToMerchant:
        return 5;
      case ReturnStatus.returnedToMerchant:
        return 6;
      case ReturnStatus.cancelled:
        return 7;
      case ReturnStatus.awaitingMerchantConfirmation:
        return 8;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case ReturnStatus.initiated:
        return "Return_Initiated".tr();
      case ReturnStatus.pickedUpFromCustomer:
        return "Picked_Up_From_Customer".tr();
      case ReturnStatus.inTransitToHub:
        return "In_Transit_To_Hub".tr();
      case ReturnStatus.atHub:
        return "At_Hub".tr();
      case ReturnStatus.inTransitToMerchant:
        return "In_Transit_To_Merchant".tr();
      case ReturnStatus.returnedToMerchant:
        return "Returned_To_Merchant".tr();
      case ReturnStatus.cancelled:
        return "Return_Cancelled".tr();
      case ReturnStatus.awaitingMerchantConfirmation:
        return "Awaiting_Merchant_Confirmation".tr();
    }
  }
}

enum ReturnMerchantAction { inTransitToMerchant, returnedToMerchant }

enum OrderStatus {
  // ==========================================
  // Creation Phase (0-99)
  // ==========================================

  /// Order created but not yet submitted
  draft,

  /// Order submitted, awaiting pickup assignment
  pendingPickup,

  // ==========================================
  // Pickup Phase (100-199)
  // ==========================================

  /// Internal driver assigned for pickup
  pickupDriverAssigned,

  /// Pickup driver en route to merchant
  pickupDriverEnRoute,

  /// Pickup driver arrived at merchant location
  pickupDriverArrived,

  /// Package picked up from merchant
  pickedUp,

  // ==========================================
  // Hub Phase (200-299)
  // ==========================================

  /// Package in transit to hub
  inTransitToHub,

  /// Package arrived at hub
  arrivedAtHub,

  /// Package being processed/sorted at hub
  processingAtHub,

  /// Package ready for transfer to another hub
  readyForTransfer,

  /// Package in transfer between hubs
  inTransferBetweenHubs,

  /// Package arrived at destination hub
  arrivedAtDestinationHub,

  /// Package ready for last-mile delivery
  readyForDelivery,

  /// Package consolidated / merged at hub (status 270)
  consolidatedAtHub,

  // ==========================================
  // Delivery Phase (300-399)
  // ==========================================

  /// Delivery driver assigned
  deliveryDriverAssigned,

  /// Driver out for delivery
  outForDelivery,

  /// Delivery driver arrived at customer location
  deliveryDriverArrived,

  /// Package delivered successfully
  delivered,

  // ==========================================
  // Exception States (400-499)
  // ==========================================

  /// Delivery attempt failed
  failedAttempt,

  /// Order needs a human decision (return / retry / escalate)
  needsAction,

  /// Package being returned
  returning,

  /// Package returned to hub
  returnedToHub,

  /// Package returned to merchant
  returnedToMerchant,

  // ==========================================
  // Terminal States (900+)
  // ==========================================

  /// Order cancelled
  cancelled;

  static OrderStatus? fromInt(int? value) {
    switch (value) {
      case 0:
        return OrderStatus.draft;
      case 10:
        return OrderStatus.pendingPickup;
      case 100:
        return OrderStatus.pickupDriverAssigned;
      case 110:
        return OrderStatus.pickupDriverEnRoute;
      case 120:
        return OrderStatus.pickupDriverArrived;
      case 130:
        return OrderStatus.pickedUp;
      case 200:
        return OrderStatus.inTransitToHub;
      case 210:
        return OrderStatus.arrivedAtHub;
      case 220:
        return OrderStatus.processingAtHub;
      case 230:
        return OrderStatus.readyForTransfer;
      case 240:
        return OrderStatus.inTransferBetweenHubs;
      case 250:
        return OrderStatus.arrivedAtDestinationHub;
      case 260:
        return OrderStatus.readyForDelivery;
      case 270:
        return OrderStatus.consolidatedAtHub;
      case 300:
        return OrderStatus.deliveryDriverAssigned;
      case 310:
        return OrderStatus.outForDelivery;
      case 320:
        return OrderStatus.deliveryDriverArrived;
      case 330:
        return OrderStatus.delivered;
      case 400:
        return OrderStatus.failedAttempt;
      case 405:
        return OrderStatus.needsAction;
      case 410:
        return OrderStatus.returning;
      case 420:
        return OrderStatus.returnedToHub;
      case 430:
        return OrderStatus.returnedToMerchant;
      case 900:
        return OrderStatus.cancelled;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case OrderStatus.draft:
        return 0;
      case OrderStatus.pendingPickup:
        return 10;
      case OrderStatus.pickupDriverAssigned:
        return 100;
      case OrderStatus.pickupDriverEnRoute:
        return 110;
      case OrderStatus.pickupDriverArrived:
        return 120;
      case OrderStatus.pickedUp:
        return 130;
      case OrderStatus.inTransitToHub:
        return 200;
      case OrderStatus.arrivedAtHub:
        return 210;
      case OrderStatus.processingAtHub:
        return 220;
      case OrderStatus.readyForTransfer:
        return 230;
      case OrderStatus.inTransferBetweenHubs:
        return 240;
      case OrderStatus.arrivedAtDestinationHub:
        return 250;
      case OrderStatus.readyForDelivery:
        return 260;
      case OrderStatus.consolidatedAtHub:
        return 270;
      case OrderStatus.deliveryDriverAssigned:
        return 300;
      case OrderStatus.outForDelivery:
        return 310;
      case OrderStatus.deliveryDriverArrived:
        return 320;
      case OrderStatus.delivered:
        return 330;
      case OrderStatus.failedAttempt:
        return 400;
      case OrderStatus.needsAction:
        return 405;
      case OrderStatus.returning:
        return 410;
      case OrderStatus.returnedToHub:
        return 420;
      case OrderStatus.returnedToMerchant:
        return 430;
      case OrderStatus.cancelled:
        return 900;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case OrderStatus.draft:
        return "Draft".tr();
      case OrderStatus.pendingPickup:
        return "Pending_Pickup".tr();
      case OrderStatus.pickupDriverAssigned:
        return "Pickup_Driver_Assigned".tr();
      case OrderStatus.pickupDriverEnRoute:
        return "Pickup_Driver_En_Route".tr();
      case OrderStatus.pickupDriverArrived:
        return "Pickup_Driver_Arrived".tr();
      case OrderStatus.pickedUp:
        return "Picked_Up".tr();
      case OrderStatus.inTransitToHub:
        return "In_Transit_to_Hub".tr();
      case OrderStatus.arrivedAtHub:
        return "arrived_at_hub".tr();
      case OrderStatus.processingAtHub:
        return "Processing_at_Hub".tr();
      case OrderStatus.readyForTransfer:
        return "Ready_for_Transfer".tr();
      case OrderStatus.inTransferBetweenHubs:
        return "In_Transfer_Between_Hubs".tr();
      case OrderStatus.arrivedAtDestinationHub:
        return "Arrived_at_Destination_Hub".tr();
      case OrderStatus.readyForDelivery:
        return "Ready_for_Delivery".tr();
      case OrderStatus.consolidatedAtHub:
        return "Consolidated_at_Hub".tr();
      case OrderStatus.deliveryDriverAssigned:
        return "Delivery_Driver_Assigned".tr();
      case OrderStatus.outForDelivery:
        return "Out_for_Delivery".tr();
      case OrderStatus.deliveryDriverArrived:
        return "Delivery_Driver_Arrived".tr();
      case OrderStatus.delivered:
        return "Delivered".tr();
      case OrderStatus.failedAttempt:
        return "Failed_Attempt".tr();
      case OrderStatus.needsAction:
        return "Needs_Action".tr();
      case OrderStatus.returning:
        return "Returning".tr();
      case OrderStatus.returnedToHub:
        return "Returned_to_Hub".tr();
      case OrderStatus.returnedToMerchant:
        return "Returned_to_Merchant".tr();
      case OrderStatus.cancelled:
        return "Cancelled".tr();
    }
  }

  /// Get status color for UI display
  Color getColor() {
    if (toInt() >= 0 && toInt() < 100) {
      return Colors.orange; // Creation phase
    } else if (toInt() >= 100 && toInt() < 200) {
      return Colors.blue; // Pickup phase
    } else if (toInt() >= 200 && toInt() < 300) {
      return Colors.purple; // Hub phase
    } else if (toInt() >= 300 && toInt() < 400) {
      return Colors.teal; // Delivery phase
    } else if (toInt() >= 400 && toInt() < 900) {
      return Colors.amber; // Exception states
    } else {
      return Colors.red; // Terminal states (cancelled)
    }
  }

  /// Get status icon for UI display
  IconData getIcon() {
    switch (this) {
      case OrderStatus.draft:
        return Icons.edit_note;
      case OrderStatus.pendingPickup:
        return Icons.schedule;
      case OrderStatus.pickupDriverAssigned:
      case OrderStatus.pickupDriverEnRoute:
      case OrderStatus.pickupDriverArrived:
        return Icons.local_shipping;
      case OrderStatus.pickedUp:
        return Icons.inventory;
      case OrderStatus.inTransitToHub:
      case OrderStatus.inTransferBetweenHubs:
        return Icons.airport_shuttle;
      case OrderStatus.arrivedAtHub:
      case OrderStatus.arrivedAtDestinationHub:
        return Icons.warehouse;
      case OrderStatus.processingAtHub:
        return Icons.sync;
      case OrderStatus.consolidatedAtHub:
        return Icons.inventory_2;
      case OrderStatus.readyForTransfer:
      case OrderStatus.readyForDelivery:
        return Icons.check_circle_outline;
      case OrderStatus.deliveryDriverAssigned:
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.deliveryDriverArrived:
        return Icons.location_on;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.failedAttempt:
        return Icons.error_outline;
      case OrderStatus.needsAction:
        return Icons.report_problem_outlined;
      case OrderStatus.returning:
      case OrderStatus.returnedToHub:
      case OrderStatus.returnedToMerchant:
        return Icons.keyboard_return;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

enum ReturnReason {
  customerRefused,
  customerNotAvailable,
  wrongAddress,
  damaged,
  customerCancelled,
  merchantRequested,
  failedDeliveryAttempts,
  wrongItemSent,
  missingItems,
  sizeOrColorMismatch,
  other;

  static ReturnReason? fromInt(int? value) {
    switch (value) {
      case 1:
        return ReturnReason.customerRefused;
      case 2:
        return ReturnReason.customerNotAvailable;
      case 3:
        return ReturnReason.wrongAddress;
      case 4:
        return ReturnReason.damaged;
      case 5:
        return ReturnReason.customerCancelled;
      case 6:
        return ReturnReason.merchantRequested;
      case 7:
        return ReturnReason.failedDeliveryAttempts;
      case 8:
        return ReturnReason.wrongItemSent;
      case 9:
        return ReturnReason.missingItems;
      case 10:
        return ReturnReason.sizeOrColorMismatch;
      case 99:
        return ReturnReason.other;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ReturnReason.customerRefused:
        return 1;
      case ReturnReason.customerNotAvailable:
        return 2;
      case ReturnReason.wrongAddress:
        return 3;
      case ReturnReason.damaged:
        return 4;
      case ReturnReason.customerCancelled:
        return 5;
      case ReturnReason.merchantRequested:
        return 6;
      case ReturnReason.failedDeliveryAttempts:
        return 7;
      case ReturnReason.wrongItemSent:
        return 8;
      case ReturnReason.missingItems:
        return 9;
      case ReturnReason.sizeOrColorMismatch:
        return 10;
      case ReturnReason.other:
        return 99;
    }
  }

  String get displayName {
    switch (this) {
      case ReturnReason.customerRefused:
        return 'Customer Refused'.tr();
      case ReturnReason.customerNotAvailable:
        return 'Customer Not Available'.tr();
      case ReturnReason.wrongAddress:
        return 'Wrong Address'.tr();
      case ReturnReason.damaged:
        return 'Damaged'.tr();
      case ReturnReason.customerCancelled:
        return 'Customer Cancelled'.tr();
      case ReturnReason.merchantRequested:
        return 'Merchant Requested'.tr();
      case ReturnReason.failedDeliveryAttempts:
        return 'Failed Delivery Attempts'.tr();
      case ReturnReason.wrongItemSent:
        return 'Wrong Item Sent'.tr();
      case ReturnReason.missingItems:
        return 'Missing Items'.tr();
      case ReturnReason.sizeOrColorMismatch:
        return 'Size or Color Mismatch'.tr();
      case ReturnReason.other:
        return 'Other'.tr();
    }
  }

  String localizedLabel(BuildContext context) {
    return displayName;
  }
}

/// Why an order is parked in [OrderStatus.needsAction] (405) — a human decision
/// is pending. Must match backend `JasimExpress.Enums.NeedsActionReason` (1..7)
/// exactly. Drivers only pick the field-relevant reasons; admin-only reasons
/// (AdminEscalation, AwaitingReDeliveryDecision) are excluded from the driver
/// picker via [driverPickable].
enum NeedsActionReason {
  failedDelivery,
  customerRefused,
  undeliverable,
  merchantRequestedReturn,
  damagedInTransit,
  adminEscalation,
  awaitingReDeliveryDecision,
  customerWantsPartialReturn,
  wrongItemSent,
  missingItems,
  sizeOrColorMismatch;

  static NeedsActionReason? fromInt(int? value) {
    switch (value) {
      case 1:
        return NeedsActionReason.failedDelivery;
      case 2:
        return NeedsActionReason.customerRefused;
      case 3:
        return NeedsActionReason.undeliverable;
      case 4:
        return NeedsActionReason.merchantRequestedReturn;
      case 5:
        return NeedsActionReason.damagedInTransit;
      case 6:
        return NeedsActionReason.adminEscalation;
      case 7:
        return NeedsActionReason.awaitingReDeliveryDecision;
      case 8:
        return NeedsActionReason.customerWantsPartialReturn;
      case 9:
        return NeedsActionReason.wrongItemSent;
      case 10:
        return NeedsActionReason.missingItems;
      case 11:
        return NeedsActionReason.sizeOrColorMismatch;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case NeedsActionReason.failedDelivery:
        return 1;
      case NeedsActionReason.customerRefused:
        return 2;
      case NeedsActionReason.undeliverable:
        return 3;
      case NeedsActionReason.merchantRequestedReturn:
        return 4;
      case NeedsActionReason.damagedInTransit:
        return 5;
      case NeedsActionReason.adminEscalation:
        return 6;
      case NeedsActionReason.awaitingReDeliveryDecision:
        return 7;
      case NeedsActionReason.customerWantsPartialReturn:
        return 8;
      case NeedsActionReason.wrongItemSent:
        return 9;
      case NeedsActionReason.missingItems:
        return 10;
      case NeedsActionReason.sizeOrColorMismatch:
        return 11;
    }
  }

  /// The reasons a driver may pick from the field "Needs Action" sheet.
  static List<NeedsActionReason> get driverPickable => const [
        NeedsActionReason.failedDelivery,
        NeedsActionReason.customerRefused,
        NeedsActionReason.undeliverable,
        NeedsActionReason.damagedInTransit,
        NeedsActionReason.customerWantsPartialReturn,
        NeedsActionReason.wrongItemSent,
        NeedsActionReason.missingItems,
        NeedsActionReason.sizeOrColorMismatch,
      ];

  String get displayName {
    switch (this) {
      case NeedsActionReason.failedDelivery:
        return 'needs_action_reason_failed_delivery'.tr();
      case NeedsActionReason.customerRefused:
        return 'needs_action_reason_customer_refused'.tr();
      case NeedsActionReason.undeliverable:
        return 'needs_action_reason_undeliverable'.tr();
      case NeedsActionReason.merchantRequestedReturn:
        return 'needs_action_reason_merchant_requested'.tr();
      case NeedsActionReason.damagedInTransit:
        return 'needs_action_reason_damaged'.tr();
      case NeedsActionReason.adminEscalation:
        return 'needs_action_reason_admin_escalation'.tr();
      case NeedsActionReason.awaitingReDeliveryDecision:
        return 'needs_action_reason_awaiting_redelivery'.tr();
      case NeedsActionReason.customerWantsPartialReturn:
        return 'needs_action_reason_partial_return'.tr();
      case NeedsActionReason.wrongItemSent:
        return 'needs_action_reason_wrong_item'.tr();
      case NeedsActionReason.missingItems:
        return 'needs_action_reason_missing_items'.tr();
      case NeedsActionReason.sizeOrColorMismatch:
        return 'needs_action_reason_size_color'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case NeedsActionReason.failedDelivery:
        return Icons.error_outline;
      case NeedsActionReason.customerRefused:
        return Icons.do_not_disturb_on_outlined;
      case NeedsActionReason.undeliverable:
        return Icons.wrong_location_outlined;
      case NeedsActionReason.merchantRequestedReturn:
        return Icons.store_outlined;
      case NeedsActionReason.damagedInTransit:
        return Icons.report_gmailerrorred_outlined;
      case NeedsActionReason.adminEscalation:
        return Icons.admin_panel_settings_outlined;
      case NeedsActionReason.awaitingReDeliveryDecision:
        return Icons.schedule_outlined;
      case NeedsActionReason.customerWantsPartialReturn:
        return Icons.call_split_outlined;
      case NeedsActionReason.wrongItemSent:
        return Icons.swap_horiz_outlined;
      case NeedsActionReason.missingItems:
        return Icons.production_quantity_limits_outlined;
      case NeedsActionReason.sizeOrColorMismatch:
        return Icons.straighten_outlined;
    }
  }
}

enum PackageCondition {
  good,
  damaged,
  opened,
  partiallyDamaged;

  static PackageCondition? fromInt(int? value) {
    switch (value) {
      case 1:
        return PackageCondition.good;
      case 2:
        return PackageCondition.damaged;
      case 3:
        return PackageCondition.opened;
      case 4:
        return PackageCondition.partiallyDamaged;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case PackageCondition.good:
        return 1;
      case PackageCondition.damaged:
        return 2;
      case PackageCondition.opened:
        return 3;
      case PackageCondition.partiallyDamaged:
        return 4;
    }
  }

  String get displayName {
    switch (this) {
      case PackageCondition.good:
        return 'Good'.tr();
      case PackageCondition.damaged:
        return 'Damaged'.tr();
      case PackageCondition.opened:
        return 'Opened'.tr();
      case PackageCondition.partiallyDamaged:
        return 'Partially Damaged'.tr();
    }
  }

  String localizedLabel(BuildContext context) {
    return displayName;
  }
}

/// Financial classification of an order return. Must match backend
/// `JasimExpress.Enums.ReturnType` (1/2/3) exactly.
enum ReturnType {
  /// Full return; refund goods value only. Customer keeps paying the delivery fee.
  fullReturnWithDeliveryFee,

  /// Full return; refund goods value + delivery fee (platform absorbs the fee).
  fullReturnWithoutDeliveryFee,

  /// Partial return; refund only returned items' value. Requires a new COD amount.
  partialReturn;

  static ReturnType? fromInt(int? value) {
    switch (value) {
      case 1:
        return ReturnType.fullReturnWithDeliveryFee;
      case 2:
        return ReturnType.fullReturnWithoutDeliveryFee;
      case 3:
        return ReturnType.partialReturn;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ReturnType.fullReturnWithDeliveryFee:
        return 1;
      case ReturnType.fullReturnWithoutDeliveryFee:
        return 2;
      case ReturnType.partialReturn:
        return 3;
    }
  }

  String get displayName {
    switch (this) {
      case ReturnType.fullReturnWithDeliveryFee:
        return 'return_type_full_with_fee'.tr();
      case ReturnType.fullReturnWithoutDeliveryFee:
        return 'return_type_full_without_fee'.tr();
      case ReturnType.partialReturn:
        return 'return_type_partial'.tr();
    }
  }

  String get description {
    switch (this) {
      case ReturnType.fullReturnWithDeliveryFee:
        return 'return_type_full_with_fee_desc'.tr();
      case ReturnType.fullReturnWithoutDeliveryFee:
        return 'return_type_full_without_fee_desc'.tr();
      case ReturnType.partialReturn:
        return 'return_type_partial_desc'.tr();
    }
  }

  String localizedLabel(BuildContext context) {
    return displayName;
  }
}

/// Source of an Express order. Must match backend `JasimExpress.Enums.OrderSource`.
/// Direct orders (0/1/2) support all return types and no sub-order. A
/// BakeetConsolidated (3) order is a multi-merchant e-commerce consolidated
/// delivery: it is returned one merchant sub-order at a time and only as a
/// full return.
enum OrderSource {
  direct,
  merchantApp,
  merchantPortal,
  bakeetConsolidated,

  /// Replacement order leg auto-created when a doorstep exchange swap completes.
  exchangeReplacement;

  static OrderSource? fromInt(int? value) {
    switch (value) {
      case 0:
        return OrderSource.direct;
      case 1:
        return OrderSource.merchantApp;
      case 2:
        return OrderSource.merchantPortal;
      case 3:
        return OrderSource.bakeetConsolidated;
      case 4:
        return OrderSource.exchangeReplacement;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case OrderSource.direct:
        return 0;
      case OrderSource.merchantApp:
        return 1;
      case OrderSource.merchantPortal:
        return 2;
      case OrderSource.bakeetConsolidated:
        return 3;
      case OrderSource.exchangeReplacement:
        return 4;
    }
  }

  bool get isConsolidated => this == OrderSource.bakeetConsolidated;
}

/// Lifecycle of an item Exchange (replacement). Must match backend
/// `JasimExpress.Enums.OrderExchangeStatus` (1..6) exactly. Phase 1 is
/// doorstep-atomic: the driver hands over the new item, takes the old one,
/// and settles the net cash in a single visit.
enum OrderExchangeStatus {
  /// Created by merchant/admin; awaiting stock confirmation.
  requested,

  /// Replacement item confirmed available (Bakeet: variant stock OK).
  merchantConfirmedStock,

  /// A driver has been assigned/scheduled for the doorstep swap.
  assigned,

  /// Doorstep-atomic swap completed: old item taken, new item given,
  /// cash difference settled.
  completed,

  /// Cancelled before the old item was taken; order value restored.
  cancelled,

  /// Could not complete the swap — converted into a plain Return + refund.
  convertedToReturn;

  static OrderExchangeStatus? fromInt(int? value) {
    switch (value) {
      case 1:
        return OrderExchangeStatus.requested;
      case 2:
        return OrderExchangeStatus.merchantConfirmedStock;
      case 3:
        return OrderExchangeStatus.assigned;
      case 4:
        return OrderExchangeStatus.completed;
      case 5:
        return OrderExchangeStatus.cancelled;
      case 6:
        return OrderExchangeStatus.convertedToReturn;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case OrderExchangeStatus.requested:
        return 1;
      case OrderExchangeStatus.merchantConfirmedStock:
        return 2;
      case OrderExchangeStatus.assigned:
        return 3;
      case OrderExchangeStatus.completed:
        return 4;
      case OrderExchangeStatus.cancelled:
        return 5;
      case OrderExchangeStatus.convertedToReturn:
        return 6;
    }
  }

  String get displayName {
    switch (this) {
      case OrderExchangeStatus.requested:
        return 'exchange_status_requested'.tr();
      case OrderExchangeStatus.merchantConfirmedStock:
        return 'exchange_status_confirmed_stock'.tr();
      case OrderExchangeStatus.assigned:
        return 'exchange_status_assigned'.tr();
      case OrderExchangeStatus.completed:
        return 'exchange_status_completed'.tr();
      case OrderExchangeStatus.cancelled:
        return 'exchange_status_cancelled'.tr();
      case OrderExchangeStatus.convertedToReturn:
        return 'exchange_status_converted_to_return'.tr();
    }
  }

  String localizedLabel(BuildContext context) => displayName;

  Color getColor() {
    switch (this) {
      case OrderExchangeStatus.requested:
        return const Color(0xFFF59E0B); // Amber
      case OrderExchangeStatus.merchantConfirmedStock:
        return const Color(0xFF3B82F6); // Blue
      case OrderExchangeStatus.assigned:
        return const Color(0xFF6366F1); // Indigo
      case OrderExchangeStatus.completed:
        return const Color(0xFF10B981); // Green
      case OrderExchangeStatus.cancelled:
        return const Color(0xFF6B7280); // Gray
      case OrderExchangeStatus.convertedToReturn:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData getIcon() {
    switch (this) {
      case OrderExchangeStatus.requested:
        return Icons.swap_horiz_rounded;
      case OrderExchangeStatus.merchantConfirmedStock:
        return Icons.inventory_2_outlined;
      case OrderExchangeStatus.assigned:
        return Icons.local_shipping_outlined;
      case OrderExchangeStatus.completed:
        return Icons.check_circle_rounded;
      case OrderExchangeStatus.cancelled:
        return Icons.block_rounded;
      case OrderExchangeStatus.convertedToReturn:
        return Icons.assignment_return_outlined;
    }
  }
}

/// Who pays the exchange redelivery fee. Must match backend
/// `JasimExpress.Enums.ExchangeFeeBearer` (1/2) exactly. The platform never
/// absorbs it; the merchant decides per exchange.
enum ExchangeFeeBearer {
  /// The customer pays the exchange delivery fee — added to what the driver
  /// collects at the doorstep (on top of any goods price difference).
  customer,

  /// The merchant pays the exchange delivery fee — charged to the merchant's
  /// account; no customer charge.
  merchant;

  static ExchangeFeeBearer? fromInt(int? value) {
    switch (value) {
      case 1:
        return ExchangeFeeBearer.customer;
      case 2:
        return ExchangeFeeBearer.merchant;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ExchangeFeeBearer.customer:
        return 1;
      case ExchangeFeeBearer.merchant:
        return 2;
    }
  }

  String get displayName {
    switch (this) {
      case ExchangeFeeBearer.customer:
        return 'exchange_fee_bearer_customer'.tr();
      case ExchangeFeeBearer.merchant:
        return 'exchange_fee_bearer_merchant'.tr();
    }
  }

  String get description {
    switch (this) {
      case ExchangeFeeBearer.customer:
        return 'exchange_fee_bearer_customer_desc'.tr();
      case ExchangeFeeBearer.merchant:
        return 'exchange_fee_bearer_merchant_desc'.tr();
    }
  }

  String localizedLabel(BuildContext context) => displayName;
}

enum DriverAssignmentStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled,
  expired;

  static DriverAssignmentStatus? fromInt(int? value) {
    switch (value) {
      case 1:
        return DriverAssignmentStatus.pending;
      case 2:
        return DriverAssignmentStatus.accepted;
      case 3:
        return DriverAssignmentStatus.rejected;
      case 4:
        return DriverAssignmentStatus.inProgress;
      case 5:
        return DriverAssignmentStatus.completed;
      case 6:
        return DriverAssignmentStatus.cancelled;
      case 7:
        return DriverAssignmentStatus.expired;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case DriverAssignmentStatus.pending:
        return 1;
      case DriverAssignmentStatus.accepted:
        return 2;
      case DriverAssignmentStatus.rejected:
        return 3;
      case DriverAssignmentStatus.inProgress:
        return 4;
      case DriverAssignmentStatus.completed:
        return 5;
      case DriverAssignmentStatus.cancelled:
        return 6;
      case DriverAssignmentStatus.expired:
        return 7;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case DriverAssignmentStatus.pending:
        return "Pending";
      case DriverAssignmentStatus.accepted:
        return "Accepted";
      case DriverAssignmentStatus.rejected:
        return "Rejected";
      case DriverAssignmentStatus.inProgress:
        return "In Progress";
      case DriverAssignmentStatus.completed:
        return "Completed";
      case DriverAssignmentStatus.cancelled:
        return "Cancelled";
      case DriverAssignmentStatus.expired:
        return "Expired";
    }
  }

  /// Get status color for UI display
  Color getColor() {
    switch (this) {
      case DriverAssignmentStatus.pending:
        return const Color(0xFFF59E0B); // Amber
      case DriverAssignmentStatus.accepted:
        return const Color(0xFF3B82F6); // Blue
      case DriverAssignmentStatus.rejected:
        return const Color(0xFFEF4444); // Red
      case DriverAssignmentStatus.inProgress:
        return const Color(0xFF6366F1); // Indigo
      case DriverAssignmentStatus.completed:
        return const Color(0xFF10B981); // Green
      case DriverAssignmentStatus.cancelled:
        return const Color(0xFF6B7280); // Gray
      case DriverAssignmentStatus.expired:
        return const Color(0xFFF87171); // Light Red
    }
  }

  /// Get status icon for UI display
  IconData getIcon() {
    switch (this) {
      case DriverAssignmentStatus.pending:
        return Icons.schedule_rounded;
      case DriverAssignmentStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case DriverAssignmentStatus.rejected:
        return Icons.cancel_outlined;
      case DriverAssignmentStatus.inProgress:
        return Icons.motion_photos_on_outlined;
      case DriverAssignmentStatus.completed:
        return Icons.check_circle_rounded;
      case DriverAssignmentStatus.cancelled:
        return Icons.block_rounded;
      case DriverAssignmentStatus.expired:
        return Icons.access_time_filled_rounded;
    }
  }
}

enum DriverAssignmentType {
  pickup,
  delivery,
  transfer,
  returnToMerchant;

  static DriverAssignmentType? fromInt(int? value) {
    switch (value) {
      case 1:
        return DriverAssignmentType.pickup;
      case 2:
        return DriverAssignmentType.delivery;
      case 3:
        return DriverAssignmentType.transfer;
      case 4:
        return DriverAssignmentType.returnToMerchant;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case DriverAssignmentType.pickup:
        return 1;
      case DriverAssignmentType.delivery:
        return 2;
      case DriverAssignmentType.transfer:
        return 3;
      case DriverAssignmentType.returnToMerchant:
        return 4;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case DriverAssignmentType.pickup:
        return "Pickup";
      case DriverAssignmentType.delivery:
        return "Delivery";
      case DriverAssignmentType.transfer:
        return "Transfer";
      case DriverAssignmentType.returnToMerchant:
        return "Return";
    }
  }
}

enum EntityType {
  compund,
  square,
  floor,
  building,
  customer,
  apartment,
  advertisement,
  service,
  categoryService,
  serviceRequest,
  visitRequest,
  complaint;

  static EntityType? fromInt(int? value) {
    switch (value) {
      case 1:
        return EntityType.compund;
      case 2:
        return EntityType.square;
      case 3:
        return EntityType.floor;
      case 4:
        return EntityType.building;
      case 5:
        return EntityType.customer;
      case 6:
        return EntityType.apartment;
      case 7:
        return EntityType.advertisement;
      case 8:
        return EntityType.service;
      case 9:
        return EntityType.categoryService;
      case 10:
        return EntityType.serviceRequest;
      case 11:
        return EntityType.visitRequest;
      case 12:
        return EntityType.complaint;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case EntityType.compund:
        return 1;
      case EntityType.square:
        return 2;
      case EntityType.floor:
        return 3;
      case EntityType.building:
        return 4;
      case EntityType.customer:
        return 5;
      case EntityType.apartment:
        return 6;
      case EntityType.advertisement:
        return 7;
      case EntityType.service:
        return 8;
      case EntityType.categoryService:
        return 9;
      case EntityType.serviceRequest:
        return 10;
      case EntityType.visitRequest:
        return 11;
      case EntityType.complaint:
        return 12;
    }
  }
}

enum OrderListFilter {
  all,
  creation,
  pickup,
  hub,
  delivery,
  exceptions,
  delivered,
  cancelled,
}
 
String filterLabel(OrderListFilter f) {
  switch (f) {
    case OrderListFilter.all:
      return 'all'.tr();
    case OrderListFilter.creation:
      return 'creation'.tr();
    case OrderListFilter.pickup:
      return 'pickup'.tr();
    case OrderListFilter.hub:
      return 'hub'.tr();
    case OrderListFilter.delivery:
      return 'delivery'.tr();
    case OrderListFilter.exceptions:
      return 'exceptions'.tr();
    case OrderListFilter.delivered:
      return 'delivered'.tr();
    case OrderListFilter.cancelled:
      return 'cancelled'.tr();
  }
}

// Empty titles/subtitles per filter (UI-only)
String emptyTitleForFilter(OrderListFilter f) {
  switch (f) {
    case OrderListFilter.all:
      return 'no_orders_yet'.tr();
    case OrderListFilter.creation:
      return 'no_creation_orders'.tr();
    case OrderListFilter.pickup:
      return 'no_pickup_orders'.tr();
    case OrderListFilter.hub:
      return 'no_hub_orders'.tr();
    case OrderListFilter.delivery:
      return 'no_delivery_orders'.tr();
    case OrderListFilter.exceptions:
      return 'no_exception_orders'.tr();
    case OrderListFilter.delivered:
      return 'no_delivered_orders'.tr();
    case OrderListFilter.cancelled:
      return 'no_cancelled_orders'.tr();
  }
}

String emptySubtitleForFilter(OrderListFilter f) {
  switch (f) {
    case OrderListFilter.all:
      return 'create_first_order'.tr();
    case OrderListFilter.creation:
      return 'no_orders_in_creation_phase'.tr();
    case OrderListFilter.pickup:
      return 'no_orders_waiting_pickup'.tr();
    case OrderListFilter.hub:
      return 'no_orders_in_hub'.tr();
    case OrderListFilter.delivery:
      return 'no_orders_in_delivery'.tr();
    case OrderListFilter.exceptions:
      return 'no_problem_orders'.tr();
    case OrderListFilter.delivered:
      return 'no_orders_delivered_yet'.tr();
    case OrderListFilter.cancelled:
      return 'no_orders_cancelled'.tr();
  }
}

IconData emptyIconForFilter(OrderListFilter f) {
  switch (f) {
    case OrderListFilter.all:
      return Icons.inventory_2_outlined;
    case OrderListFilter.creation:
      return Icons.edit_note;
    case OrderListFilter.pickup:
      return Icons.local_shipping;
    case OrderListFilter.hub:
      return Icons.warehouse;
    case OrderListFilter.delivery:
      return Icons.delivery_dining;
    case OrderListFilter.exceptions:
      return Icons.error_outline;
    case OrderListFilter.delivered:
      return Icons.check_circle;
    case OrderListFilter.cancelled:
      return Icons.cancel;
  }
}

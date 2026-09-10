import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// ===============================
/// FreightMode
/// ===============================
enum FreightMode {
  air,
  land,
  sea;

  static FreightMode? fromInt(int? value) {
    switch (value) {
      case 1:
        return FreightMode.air;
      case 2:
        return FreightMode.sea;
      case 3:
        return FreightMode.land;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case FreightMode.air:
        return 1;
      case FreightMode.sea:
        return 2;
      case FreightMode.land:
        return 3;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case FreightMode.air:
        return "FreightMode_Air".tr(); // ترجمها في ملف اللغات
      case FreightMode.land:
        return "FreightMode_Land".tr();
      case FreightMode.sea:
        return "FreightMode_Sea".tr();
    }
  }
}

/// ===============================
/// ShipmentIncoterms
/// ===============================
enum ShipmentIncoterms {
  exw,
  fob,
  cif,
  dap;

  static ShipmentIncoterms? fromInt(int? value) {
    switch (value) {
      case 1:
        return ShipmentIncoterms.exw;
      case 2:
        return ShipmentIncoterms.fob;
      case 3:
        return ShipmentIncoterms.cif;
      case 4:
        return ShipmentIncoterms.dap;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ShipmentIncoterms.exw:
        return 1;
      case ShipmentIncoterms.fob:
        return 2;
      case ShipmentIncoterms.cif:
        return 3;
      case ShipmentIncoterms.dap:
        return 4;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case ShipmentIncoterms.exw:
        return "EXW";
      case ShipmentIncoterms.fob:
        return "FOB";
      case ShipmentIncoterms.cif:
        return "CIF";
      case ShipmentIncoterms.dap:
        return "DAP";
    }
  }
}

/// ===============================
/// ShipmentBookingSource
/// ===============================
enum ShipmentBookingSource {
  web,
  portal,
  mobile;

  static ShipmentBookingSource? fromInt(int? value) {
    switch (value) {
      case 1:
        return ShipmentBookingSource.web;
      case 2:
        return ShipmentBookingSource.portal;
      case 3:
        return ShipmentBookingSource.mobile;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ShipmentBookingSource.web:
        return 1;
      case ShipmentBookingSource.portal:
        return 2;
      case ShipmentBookingSource.mobile:
        return 3;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case ShipmentBookingSource.web:
        return "BookingSource_Web".tr();
      case ShipmentBookingSource.portal:
        return "BookingSource_Portal".tr();
      case ShipmentBookingSource.mobile:
        return "BookingSource_Mobile".tr();
    }
  }
}

/// ===============================
/// FreightType
/// ===============================
enum FreightType {
  fcl,
  lcl;

  static FreightType? fromInt(int? value) {
    switch (value) {
      case 1:
        return FreightType.fcl;
      case 2:
        return FreightType.lcl;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case FreightType.fcl:
        return 1;
      case FreightType.lcl:
        return 2;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case FreightType.fcl:
        return "FCL";
      case FreightType.lcl:
        return "LCL";
    }
  }
}

/// ===============================
/// ShipmentBookingStatus
/// ===============================
enum ShipmentBookingStatus {
  open,
  onTheWay,
  arrivedToWarehouse;

  static ShipmentBookingStatus? fromInt(int? value) {
    switch (value) {
      case 1:
        return ShipmentBookingStatus.open;
      case 2:
        return ShipmentBookingStatus.onTheWay;
      case 3:
        return ShipmentBookingStatus.arrivedToWarehouse;

      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ShipmentBookingStatus.open:
        return 1;
      case ShipmentBookingStatus.onTheWay:
        return 2;
      case ShipmentBookingStatus.arrivedToWarehouse:
        return 3;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case ShipmentBookingStatus.open:
        return "Open";
      case ShipmentBookingStatus.onTheWay:
        return "On The Way";
      case ShipmentBookingStatus.arrivedToWarehouse:
        return "Arrived To Warehouse";
    }
  }

  Color statusColor() {
    switch (this) {
      case ShipmentBookingStatus.open:
        return const Color(0xFF6366F1); // indigo
      case ShipmentBookingStatus.onTheWay:
        return const Color(0xFFF59E0B); // amber
      case ShipmentBookingStatus.arrivedToWarehouse:
        return const Color(0xFF10B981); // emerald
    }
  }
}

/// ===============================
/// ShipmentTransactionType
/// ===============================

enum ShipmentTransactionType {
  /// محجوزة - Booked
  booked,

  /// تم استلام البضاعة في المخزن - Received at Warehouse
  receivedAtWarehouse,

  /// تم تحميل البضاعة على الشحنة - Loaded to Freight
  loadedToFreight,

  /// إرجاع من المركز/Hub - Returned from Hub
  returnedFromHub,

  /// إرجاع من الشحنة - Returned from Freight
  returnedFromFreight,

  /// غادرت الشحنة - Shipment Departed
  shipmentDeparted,

  /// وصلت الشحنة - Arrived at Hub
  arrivedAtHub,

  /// الوصول النهائي والتسليم - Delivered to Destination
  deliveredToDestination;

  static ShipmentTransactionType? fromInt(int? value) {
    switch (value) {
      case 0:
        return ShipmentTransactionType.booked;
      case 1:
        return ShipmentTransactionType.receivedAtWarehouse;
      case 2:
        return ShipmentTransactionType.loadedToFreight;
      case 3:
        return ShipmentTransactionType.returnedFromHub;
      case 4:
        return ShipmentTransactionType.returnedFromFreight;
      case 5:
        return ShipmentTransactionType.shipmentDeparted;
      case 6:
        return ShipmentTransactionType.arrivedAtHub;
      case 7:
        return ShipmentTransactionType.deliveredToDestination;
      default:
        return null;
    }
  }

  int toInt() {
    switch (this) {
      case ShipmentTransactionType.booked:
        return 0;
      case ShipmentTransactionType.receivedAtWarehouse:
        return 1;
      case ShipmentTransactionType.loadedToFreight:
        return 2;
      case ShipmentTransactionType.returnedFromHub:
        return 3;
      case ShipmentTransactionType.returnedFromFreight:
        return 4;
      case ShipmentTransactionType.shipmentDeparted:
        return 5;
      case ShipmentTransactionType.arrivedAtHub:
        return 6;
      case ShipmentTransactionType.deliveredToDestination:
        return 7;
    }
  }

  String localizedLabel(BuildContext context) {
    switch (this) {
      case ShipmentTransactionType.booked:
        return "Shipment_Transaction_Booked".tr();
      case ShipmentTransactionType.receivedAtWarehouse:
        return "Shipment_Transaction_ReceivedAtWarehouse".tr();
      case ShipmentTransactionType.loadedToFreight:
        return "Shipment_Transaction_LoadedToFreight".tr();
      case ShipmentTransactionType.returnedFromHub:
        return "Shipment_Transaction_ReturnedFromHub".tr();
      case ShipmentTransactionType.returnedFromFreight:
        return "Shipment_Transaction_ReturnedFromFreight".tr();
      case ShipmentTransactionType.shipmentDeparted:
        return "Shipment_Transaction_ShipmentDeparted".tr();
      case ShipmentTransactionType.arrivedAtHub:
        return "Shipment_Transaction_ArrivedAtHub".tr();
      case ShipmentTransactionType.deliveredToDestination:
        return "Shipment_Transaction_DeliveredToDestination".tr();
    }
  }

  String shortLabel(BuildContext context) {
    switch (this) {
      case ShipmentTransactionType.booked:
        return 'Booked'.tr();
      case ShipmentTransactionType.receivedAtWarehouse:
        return 'Received'.tr();
      case ShipmentTransactionType.loadedToFreight:
        return 'Loaded'.tr();
      case ShipmentTransactionType.returnedFromHub:
        return 'Returned_Hub'.tr();
      case ShipmentTransactionType.returnedFromFreight:
        return 'Returned_Freight'.tr();
      case ShipmentTransactionType.shipmentDeparted:
        return 'Departed'.tr();
      case ShipmentTransactionType.arrivedAtHub:
        return 'Arrived'.tr();
      case ShipmentTransactionType.deliveredToDestination:
        return 'Delivered'.tr();
    }
  }

  IconData get icon {
    switch (this) {
      case ShipmentTransactionType.booked:
        return Icons.assignment_outlined;
      case ShipmentTransactionType.receivedAtWarehouse:
        return Icons.check_circle_outline;
      case ShipmentTransactionType.loadedToFreight:
        return Icons.local_shipping_outlined;
      case ShipmentTransactionType.returnedFromHub:
        return Icons.keyboard_return_rounded;
      case ShipmentTransactionType.returnedFromFreight:
        return Icons.undo_rounded;
      case ShipmentTransactionType.shipmentDeparted:
        return Icons.flight_takeoff_rounded;
      case ShipmentTransactionType.arrivedAtHub:
        return Icons.flight_land_rounded;
      case ShipmentTransactionType.deliveredToDestination:
        return Icons.done_all_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ShipmentTransactionType.booked:
        return const Color(0xFFEAB308); // yellow
      case ShipmentTransactionType.receivedAtWarehouse:
        return const Color(0xFF22C55E); // green
      case ShipmentTransactionType.loadedToFreight:
        return const Color(0xFF16A34A); // green
      case ShipmentTransactionType.returnedFromHub:
        return const Color(0xFFF59E0B); // orange
      case ShipmentTransactionType.returnedFromFreight:
        return const Color(0xFFEF4444); // red
      case ShipmentTransactionType.shipmentDeparted:
        return const Color(0xFF84CC16); // lime
      case ShipmentTransactionType.arrivedAtHub:
        return const Color(0xFF0EA5E9); // sky
      case ShipmentTransactionType.deliveredToDestination:
        return const Color(0xFF10B981); // emerald
    }
  }

  String get id {
    switch (this) {
      case ShipmentTransactionType.booked:
        return 'booked';
      case ShipmentTransactionType.receivedAtWarehouse:
        return 'receivedAtWarehouse';
      case ShipmentTransactionType.loadedToFreight:
        return 'loadedToFreight';
      case ShipmentTransactionType.returnedFromHub:
        return 'returnedFromHub';
      case ShipmentTransactionType.returnedFromFreight:
        return 'returnedFromFreight';
      case ShipmentTransactionType.shipmentDeparted:
        return 'shipmentDeparted';
      case ShipmentTransactionType.arrivedAtHub:
        return 'arrivedAtHub';
      case ShipmentTransactionType.deliveredToDestination:
        return 'deliveredToDestination';
    }
  }
}

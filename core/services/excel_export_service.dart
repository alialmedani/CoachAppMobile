// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter/material.dart';
// import '../../features/Express/user/order/data/model/order_model.dart';

// class ExcelExportService {
//   static Future<String> exportOrdersToExcel(List<OrderModel> orders) async {
//     try {
//       debugPrint('📊 Starting Excel export for ${orders.length} orders');
//       final excel = Excel.createExcel();

//       excel.delete('Sheet1');
//       excel.copy('Sheet1', 'Orders');
//       excel.delete('Sheet1');

//       final sheet = excel['Orders'];

//       final headers = [
//         'Tracking Number',
//         'Merchant',
//         'Recipient Name',
//         'Recipient Phone',
//         'Pickup Province',
//         'Pickup District',
//         'Pickup Address',
//         'Delivery Province',
//         'Delivery District',
//         'Delivery Address',
//         'Package Size',
//         'Service Type',
//         'Weight',
//         'Quantity',
//         'Description',
//         'Delivery Fee',
//         'COD Amount',
//         'Is COD',
//         'Status',
//         'Pickup Scheduled',
//         'Picked Up At',
//         'Delivered At',
//         'Pickup Driver',
//         'Delivery Driver',
//         'Current Hub',
//         'Creation Time',
//       ];

//       for (int i = 0; i < headers.length; i++) {
//         final cell = sheet.cell(
//           CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
//         );
//         cell.value = TextCellValue(headers[i]);
//         cell.cellStyle = CellStyle(
//           bold: true,
//           backgroundColorHex: ExcelColor.grey,
//           horizontalAlign: HorizontalAlign.Center,
//         );
//       }

//       for (int rowIndex = 0; rowIndex < orders.length; rowIndex++) {
//         final order = orders[rowIndex];
//         final dataRow = [
//           order.trackingNumber ?? '',
//           order.merchantBusinessName ?? '',
//           order.recipientName ?? '',
//           order.recipientPhone ?? '',
//           order.pickupProvinceName ?? '',
//           order.pickupDistrictName ?? '',
//           _formatAddress(
//             order.pickupStreet,
//             order.pickupBuildingNumber,
//             order.pickupFloor,
//             order.pickupApartment,
//           ),
//           order.deliveryProvinceName ?? '',
//           order.deliveryDistrictName ?? '',
//           _formatAddress(
//             order.deliveryStreet,
//             order.deliveryBuildingNumber,
//             order.deliveryFloor,
//             order.deliveryApartment,
//           ),
//           _getPackageSizeText(order.packageSize),
//           _getServiceTypeText(order.serviceType),
//           order.weight?.toString() ?? '',
//           order.quantity?.toString() ?? '',
//           order.description ?? '',
//           order.deliveryFee?.toString() ?? '',
//           order.codAmount?.toString() ?? '',
//           order.isCOD == true ? 'Yes' : 'No',
//           _getStatusText(order.status),
//           _formatDate(order.pickupScheduledAt),
//           _formatDate(order.pickedUpAt),
//           _formatDate(order.deliveredAt),
//           order.pickupDriverName ?? '',
//           order.deliveryDriverName ?? '',
//           order.currentHubName ?? '',
//           _formatDate(order.creationTime),
//         ];

//         for (int colIndex = 0; colIndex < dataRow.length; colIndex++) {
//           final cell = sheet.cell(
//             CellIndex.indexByColumnRow(
//               columnIndex: colIndex,
//               rowIndex: rowIndex + 1,
//             ),
//           );
//           cell.value = TextCellValue(dataRow[colIndex]);
//         }
//       }

//       for (int i = 0; i < headers.length; i++) {
//         sheet.setColumnWidth(i, 20);
//       }

//       debugPrint('📝 Encoding Excel file...');
//       final fileBytes = excel.encode();
//       if (fileBytes == null) {
//         throw Exception('Failed to encode Excel file');
//       }

//       // Use application documents directory for better iOS compatibility
//       final directory = Platform.isIOS
//           ? await getApplicationDocumentsDirectory()
//           : await getTemporaryDirectory();

//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       final fileName = 'orders_export_$timestamp.xlsx';
//       final filePath = '${directory.path}/$fileName';

//       debugPrint('💾 Saving file to: $filePath');
//       final file = File(filePath);
//       await file.create(recursive: true);
//       await file.writeAsBytes(fileBytes);

//       debugPrint('📤 Sharing file via share sheet...');
//       // Share the file with proper MIME type
//       final result = await Share.shareXFiles(
//         [
//           XFile(
//             filePath,
//             mimeType:
//                 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
//           ),
//         ],
//         subject: 'Orders Export - ${orders.length} orders',
//         text: 'Exported ${orders.length} orders from Noon Express',
//         sharePositionOrigin: const Rect.fromLTWH(
//           0,
//           0,
//           10,
//           10,
//         ), // iOS needs this for iPad
//       );

//       debugPrint('✅ Share completed with status: ${result.status}');
//       return filePath;
//     } catch (e, stackTrace) {
//       debugPrint('❌ Excel export error: $e');
//       debugPrint('Stack trace: $stackTrace');
//       throw Exception('Error exporting to Excel: $e');
//     }
//   }

//   static String _formatAddress(
//     String? street,
//     String? building,
//     String? floor,
//     String? apartment,
//   ) {
//     final parts = <String>[];
//     if (street != null && street.isNotEmpty) parts.add(street);
//     if (building != null && building.isNotEmpty) parts.add('Bldg: $building');
//     if (floor != null && floor.isNotEmpty) parts.add('Floor: $floor');
//     if (apartment != null && apartment.isNotEmpty) parts.add('Apt: $apartment');
//     return parts.join(', ');
//   }

//   static String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return '';
//     try {
//       final date = DateTime.parse(dateString);
//       return DateFormat('yyyy-MM-dd HH:mm').format(date);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   static String _getStatusText(num? status) {
//     if (status == null) return '';
//     final statusMap = {
//       0: 'Pending',
//       100: 'Assigned to Pickup Driver',
//       110: 'Pickup in Progress',
//       120: 'Ready for Pickup',
//       130: 'Picked Up',
//       200: 'At Hub',
//       300: 'Assigned to Delivery Driver',
//       310: 'Out for Delivery',
//       400: 'Delivered',
//       500: 'Cancelled',
//     };
//     return statusMap[status.toInt()] ?? 'Status $status';
//   }

//   static String _getPackageSizeText(num? size) {
//     if (size == null) return '';
//     final sizeMap = {1: 'Small', 2: 'Medium', 3: 'Large', 4: 'Extra Large'};
//     return sizeMap[size.toInt()] ?? 'Size $size';
//   }

//   static String _getServiceTypeText(num? type) {
//     if (type == null) return '';
//     final typeMap = {1: 'Standard', 2: 'Express', 3: 'Same Day'};
//     return typeMap[type.toInt()] ?? 'Type $type';
//   }
// }

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:latlong2/latlong.dart';

// import '../../constant/app_colors/app_colors.dart';
// import '../../utils/functions/location.dart';
// import '../../variables/variables.dart' as globals;

// class MapLocationPicker extends StatefulWidget {
//   final LatLng? initialLocation;
//   final Function(LatLng location, Placemark? address) onLocationSelected;

//   const MapLocationPicker({
//     super.key,
//     this.initialLocation,
//     required this.onLocationSelected,
//   });

//   @override
//   State<MapLocationPicker> createState() => _MapLocationPickerState();
// }

// class _MapLocationPickerState extends State<MapLocationPicker> {
//   final MapController _mapController = MapController();
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//   LatLng? _selectedLocation;
//   Placemark? _selectedAddress;
//   bool _isLoadingAddress = false;
//   bool _isLoadingCurrentLocation = false;
//   bool _isSearching = false;
//   List<Location> _searchResults = [];
//   Map<int, Placemark> _searchResultAddresses =
//       {}; // Store addresses for search results
//   bool _showSearchResults = false;

//   @override
//   void initState() {
//     super.initState();
//     _selectedLocation =
//         widget.initialLocation ?? LatLng(33.3152, 44.3661); // Baghdad default

//     // Listen to search focus to show/hide results
//     _searchFocusNode.addListener(() {
//       if (!_searchFocusNode.hasFocus && mounted) {
//         // Delay hiding to allow tap on results
//         Future.delayed(const Duration(milliseconds: 200), () {
//           if (mounted) {
//             setState(() {
//               _showSearchResults = false;
//             });
//           }
//         });
//       }
//     });

//     // Automatically get current location on page open if no initial location provided
//     if (widget.initialLocation == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _getCurrentLocation();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoadingCurrentLocation = true;
//     });

//     try {
//       // Use the GetLocation utility class
//       await GetLocation().getLocation();

//       // Check if location was successfully retrieved
//       if (globals.currentLocation != null) {
//         final newLocation = globals.currentLocation!;
//         setState(() {
//           _selectedLocation = newLocation;
//         });
//         _mapController.move(newLocation, 15.0);
//         await _getAddressFromLocation(newLocation);
//       } else {
//         // Location not available
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('could_not_get_current_location'.tr()),
//               backgroundColor: AppColors.warning,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${'error_getting_location'.tr()}: $e'),
//             backgroundColor: AppColors.danger,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoadingCurrentLocation = false;
//       });
//     }
//   }

//   Future<void> _searchLocation(String query) async {
//     if (query.trim().isEmpty) {
//       setState(() {
//         _searchResults = [];
//         _searchResultAddresses = {};
//         _showSearchResults = false;
//       });
//       return;
//     }

//     setState(() {
//       _isSearching = true;
//       _showSearchResults = true;
//     });

//     try {
//       // Search for locations matching the query
//       List<Location> locations = await locationFromAddress(query);

//       if (mounted) {
//         setState(() {
//           _searchResults = locations;
//         });

//         // Fetch addresses for each result
//         _searchResultAddresses = {};
//         for (int i = 0; i < locations.length && i < 5; i++) {
//           try {
//             final placemarks = await placemarkFromCoordinates(
//               locations[i].latitude,
//               locations[i].longitude,
//             );
//             if (placemarks.isNotEmpty && mounted) {
//               setState(() {
//                 _searchResultAddresses[i] = placemarks.first;
//               });
//             }
//           } catch (e) {
//             debugPrint('Error getting address for result $i: $e');
//           }
//         }

//         if (mounted) {
//           setState(() {
//             _isSearching = false;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error searching location: $e');
//       if (mounted) {
//         setState(() {
//           _searchResults = [];
//           _searchResultAddresses = {};
//           _isSearching = false;
//         });
//       }
//     }
//   }

//   Future<void> _selectSearchResult(Location location) async {
//     final newLocation = LatLng(location.latitude, location.longitude);

//     setState(() {
//       _selectedLocation = newLocation;
//       _showSearchResults = false;
//     });

//     // Move map to selected location
//     _mapController.move(newLocation, 15.0);

//     // Get detailed address for this location
//     await _getAddressFromLocation(newLocation);

//     // Clear search field focus
//     _searchFocusNode.unfocus();
//   }

//   Future<void> _getAddressFromLocation(LatLng location) async {
//     setState(() {
//       _isLoadingAddress = true;
//     });

//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         location.latitude.toDouble(),
//         location.longitude.toDouble(),
//       );

//       if (placemarks.isNotEmpty) {
//         setState(() {
//           _selectedAddress = placemarks.first;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error getting address: $e');
//     } finally {
//       setState(() {
//         _isLoadingAddress = false;
//       });
//     }
//   }

//   void _onMapTap(TapPosition tapPosition, LatLng location) {
//     setState(() {
//       _selectedLocation = location;
//     });
//     _getAddressFromLocation(location);
//   }

//   void _confirmLocation() {
//     if (_selectedLocation != null) {
//       widget.onLocationSelected(_selectedLocation!, _selectedAddress);
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: AppColors.primary,
//         title: Text(
//           'select_location'.tr(),
//           style: const TextStyle(
//             color: AppColors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: AppColors.white),
//       ),
//       body: Stack(
//         children: [
//           // Map
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _selectedLocation!,
//               initialZoom: 15.0,
//               onTap: _onMapTap,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.enjaz.noon_express',
//               ),
//               if (_selectedLocation != null)
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: _selectedLocation!,
//                       width: 50.w,
//                       height: 50.h,
//                       child: Icon(
//                         Icons.location_on,
//                         color: AppColors.danger,
//                         size: 50.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),

//           // Search bar with results
//           Positioned(
//             top: 16.h,
//             left: 16.w,
//             right: 16.w,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Search field
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.white,
//                     borderRadius: BorderRadius.circular(12.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.neutral900.withAlpha(25),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     focusNode: _searchFocusNode,
//                     decoration: InputDecoration(
//                       hintText: 'search_for_place'.tr(),
//                       hintStyle: TextStyle(
//                         fontSize: 14.sp,
//                         color: AppColors.neutral600,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: AppColors.primary,
//                         size: 24.sp,
//                       ),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: Icon(
//                                 Icons.clear,
//                                 color: AppColors.neutral600,
//                                 size: 20.sp,
//                               ),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 setState(() {
//                                   _searchResults = [];
//                                   _searchResultAddresses = {};
//                                   _showSearchResults = false;
//                                 });
//                               },
//                             )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 16.h,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setState(() {}); // Update to show/hide clear button
//                       if (value.length >= 3) {
//                         _searchLocation(value);
//                       } else {
//                         setState(() {
//                           _searchResults = [];
//                           _searchResultAddresses = {};
//                           _showSearchResults = false;
//                         });
//                       }
//                     },
//                     onSubmitted: (value) {
//                       if (value.isNotEmpty) {
//                         _searchLocation(value);
//                       }
//                     },
//                   ),
//                 ),

//                 // Search results dropdown
//                 if (_showSearchResults)
//                   Container(
//                     margin: EdgeInsets.only(top: 8.h),
//                     constraints: BoxConstraints(maxHeight: 250.h),
//                     decoration: BoxDecoration(
//                       color: AppColors.white,
//                       borderRadius: BorderRadius.circular(12.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.neutral900.withAlpha(25),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: _isSearching
//                         ? Padding(
//                             padding: EdgeInsets.all(16.w),
//                             child: const Center(
//                               child: CircularProgressIndicator(),
//                             ),
//                           )
//                         : _searchResults.isEmpty
//                         ? Padding(
//                             padding: EdgeInsets.all(16.w),
//                             child: Center(
//                               child: Text(
//                                 'no_results_found'.tr(),
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   color: AppColors.neutral600,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : ListView.separated(
//                             shrinkWrap: true,
//                             padding: EdgeInsets.zero,
//                             itemCount: _searchResults.length > 5
//                                 ? 5
//                                 : _searchResults.length,
//                             separatorBuilder: (context, index) =>
//                                 Divider(height: 1, color: AppColors.neutral200),
//                             itemBuilder: (context, index) {
//                               final location = _searchResults[index];
//                               final address = _searchResultAddresses[index];

//                               // Build title from address components
//                               String title;
//                               if (address != null) {
//                                 if (address.street != null &&
//                                     address.street!.isNotEmpty) {
//                                   title = address.street!;
//                                 } else if (address.locality != null &&
//                                     address.locality!.isNotEmpty) {
//                                   title = address.locality!;
//                                 } else if (address.subAdministrativeArea !=
//                                     null) {
//                                   title = address.subAdministrativeArea!;
//                                 } else if (address.administrativeArea != null) {
//                                   title = address.administrativeArea!;
//                                 } else {
//                                   title = 'Location ${index + 1}';
//                                 }
//                               } else {
//                                 title = 'Location ${index + 1}';
//                               }

//                               // Build subtitle from address components
//                               String subtitle;
//                               if (address != null) {
//                                 List<String> parts = [];
//                                 if (address.locality != null &&
//                                     address.locality!.isNotEmpty) {
//                                   parts.add(address.locality!);
//                                 }
//                                 if (address.administrativeArea != null &&
//                                     address.administrativeArea!.isNotEmpty) {
//                                   parts.add(address.administrativeArea!);
//                                 }
//                                 if (address.country != null &&
//                                     address.country!.isNotEmpty) {
//                                   parts.add(address.country!);
//                                 }

//                                 if (parts.isNotEmpty) {
//                                   subtitle = parts.join(', ');
//                                 } else {
//                                   subtitle =
//                                       'Lat: ${location.latitude.toStringAsFixed(4)}, '
//                                       'Lng: ${location.longitude.toStringAsFixed(4)}';
//                                 }
//                               } else {
//                                 subtitle =
//                                     'Lat: ${location.latitude.toStringAsFixed(4)}, '
//                                     'Lng: ${location.longitude.toStringAsFixed(4)}';
//                               }

//                               return ListTile(
//                                 dense: true,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 16.w,
//                                   vertical: 8.h,
//                                 ),
//                                 leading: Container(
//                                   padding: EdgeInsets.all(8.w),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.primary.withAlpha(25),
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: Icon(
//                                     Icons.place,
//                                     color: AppColors.primary,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                                 title: Text(
//                                   title,
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 subtitle: Text(
//                                   subtitle,
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     color: AppColors.neutral600,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 trailing: address == null
//                                     ? SizedBox(
//                                         width: 16.w,
//                                         height: 16.h,
//                                         child: const CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 16.sp,
//                                         color: AppColors.neutral400,
//                                       ),
//                                 onTap: () => _selectSearchResult(location),
//                               );
//                             },
//                           ),
//                   ),
//               ],
//             ),
//           ),

//           // Address info card (moved below search)
//           if (_selectedLocation != null && !_showSearchResults)
//             Positioned(
//               top: 90.h,
//               left: 16.w,
//               right: 16.w,
//               child: Container(
//                 padding: EdgeInsets.all(16.w),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.neutral900.withAlpha(25),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on,
//                           color: AppColors.primary,
//                           size: 20.sp,
//                         ),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'selected_location'.tr(),
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.neutral900,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8.h),
//                     if (_isLoadingAddress)
//                       Row(
//                         children: [
//                           const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                           const SizedBox(width: 8),
//                           Text('getting_address'.tr()),
//                         ],
//                       )
//                     else if (_selectedAddress != null)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (_selectedAddress!.street != null)
//                             Text(
//                               _selectedAddress!.street!,
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: AppColors.neutral600,
//                               ),
//                             ),
//                           if (_selectedAddress!.locality != null ||
//                               _selectedAddress!.administrativeArea != null)
//                             Text(
//                               '${_selectedAddress!.locality ?? ''}, ${_selectedAddress!.administrativeArea ?? ''}',
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: AppColors.neutral600,
//                               ),
//                             ),
//                         ],
//                       )
//                     else
//                       Text(
//                         'tap_on_map_to_select'.tr(),
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: AppColors.neutral600,
//                         ),
//                       ),
//                     SizedBox(height: 8.h),
//                     if (_selectedLocation != null)
//                       Text(
//                         'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
//                         'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: AppColors.neutral,
//                           fontFamily: 'monospace',
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//           // Current location button
//           Positioned(
//             right: 16.w,
//             bottom: 100.h,
//             child: FloatingActionButton(
//               heroTag: 'current_location',
//               onPressed: _isLoadingCurrentLocation ? null : _getCurrentLocation,
//               backgroundColor: AppColors.white,
//               child: _isLoadingCurrentLocation
//                   ? SizedBox(
//                       width: 24.w,
//                       height: 24.h,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppColors.primary,
//                       ),
//                     )
//                   : Icon(
//                       Icons.my_location,
//                       color: AppColors.primary,
//                       size: 24.sp,
//                     ),
//             ),
//           ),

//           // Confirm button
//           Positioned(
//             bottom: 16.h,
//             left: 16.w,
//             right: 16.w,
//             child: ElevatedButton(
//               onPressed: _selectedLocation != null ? _confirmLocation : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(vertical: 16.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 elevation: 4,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.check, color: AppColors.white, size: 24.sp),
//                   SizedBox(width: 8.w),
//                   Text(
//                     'confirm_location'.tr(),
//                     style: TextStyle(
//                       color: AppColors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

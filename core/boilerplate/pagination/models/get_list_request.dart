class GetListRequest {
  int? skip;
  int? take;
  String?
  searchTerm; // Search query - searches across TrackingNumber, RecipientName, RecipientPhone
  String? merchantId; // Filter by merchant ID
  String? pickupDistrictId; // Filter by pickup district ID (deprecated)
  String?
  deliveryDistrictId; // Filter by delivery district/place ID (driver area chip)
  String? district; // Filter by district name
  int? status; // Filter by order status

  GetListRequest({
    this.skip,
    this.take,
    this.searchTerm,
    this.merchantId,
    this.pickupDistrictId,
    this.deliveryDistrictId,
    this.district,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (skip != null) data['SkipCount'] = skip;
    if (take != null) data['MaxResultCount'] = take;
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      data['SearchTerm'] = searchTerm;
    }
    if (merchantId != null) data['MerchantId'] = merchantId;
    if (pickupDistrictId != null) data['PickupDistrictId'] = pickupDistrictId;
    if (deliveryDistrictId != null) {
      data['DeliveryDistrictId'] = deliveryDistrictId;
    }
    if (district != null) data['District'] = district;
    if (status != null) data['Status'] = status;
    return data;
  }
}

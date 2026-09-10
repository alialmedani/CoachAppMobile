import '../enum/enum.dart';

// const baseUrl = 'https://lv98z8gwog3m.shares.zrok.io/';
// const baseUrl = 'https://api.demo.bakeet.shop/';
const baseUrl = 'https://api.express1.jasim-erp.com/';
// const baseUrl = 'http://10.0.2.2:5000/';

const baseFrightUrl = 'https://api.uat.jasim-erp.com/';

var baseImageUrl = "${baseUrl}api/app/document/by-master/";
const loginUrl = '${baseUrl}connect/token';
const registerUrl = '${baseUrl}api/app/mobile-user';
const verifyOtpUrl = '${baseUrl}api/account/verify-otp';
const registerDriverUrl = '${baseUrl}api/account/register-driver';
const registerMerchantUrl = '${baseUrl}api/account/register-merchant';
const sendOtpUrl = '${baseUrl}api/account/send-otp';
const changePasswordUrl = '${baseUrl}api/account/change-password';
const forceChangePasswordUrl = '${baseUrl}api/account/set-password';
const setPasswordUrl = '${baseUrl}api/account/set-password';
const getUserByUsernameUrl = '${baseUrl}api/app/identity-user/by-user-name';
String getResetPasswordUrl(String userId) =>
    '${baseUrl}api/app/identity-user/$userId/change-password';
const deleteDocumentUrl = '${baseUrl}api/app/document';
const uploadCuurentUserDocumentUrl =
    '${baseUrl}api/app/document/upload-many/current_user';
const uploadManyDocumentUrl = '${baseUrl}api/app/document/upload-many';
const uploadOneDocumentUrl = '${baseUrl}api/app/document/upload';

const setDeviceIdUrl = '${baseUrl}api/app/user/set-device-id';

/////// notifications ////////
const getMyNotificationsUrl = '${baseUrl}api/notifications/my-notifications';
const getUnreadNotificationsCountUrl =
    '${baseUrl}api/notifications/unread-count';
const markAllNotificationsReadUrl =
    '${baseUrl}api/notifications/mark-all-as-read';
String markNotificationReadUrl(String id) =>
    '${baseUrl}api/notifications/$id/mark-as-read';
const currentUserComplaintUrl =
    '${baseUrl}api/app/complaint/api/app/complaint/current_user';

const appConfigUrl = '${baseUrl}api/abp/application-configuration';

/////// order ////////
const createOrderUrl = '${baseUrl}api/orders/from-mobile';
const getMerchantOrderUrl = '${baseUrl}api/orders/my-orders';
const getOrderUrl = '${baseUrl}api/orders';
const getDriverOrdersGroupedUrl =
    '${baseUrl}api/orders/my-driver-orders-grouped';
String getConsolidationGroupUrl(String consolidationGroupId) =>
    '${baseUrl}api/orders/consolidation-groups/$consolidationGroupId';
const checkQrCodeAvailabilityUrl =
    '${baseUrl}api/qr-code-blanks/check-availability';
const getPricingSettingsUrl = '${baseUrl}api/app/pricing-settings';
const getMerchantPricingSettingsUrl =
    '${baseUrl}api/app/pricing-settings/merchant';

/////// order return ////////

const String createOrderReturnUrl = '/api/order-returns';
const String getOrderReturnsUrl = '${baseUrl}api/order-returns';

// Merchant confirms receipt of a returned parcel (single, optionally by QR) or in bulk.
String confirmReturnReceiptUrl(String id) =>
    '${baseUrl}api/order-returns/$id/confirm-receipt-by-merchant';
const String confirmReturnReceiptBulkUrl =
    '${baseUrl}api/order-returns/confirm-receipt-bulk';

/////// order actions (NeedsAction) ////////
// Driver flags an order as Needs Action (status 405) with a reason. This does
// NOT create a return — it parks the order pending an admin/merchant decision
// and leaves the parcel with the driver. Maps to OrderController.MarkNeedsAction.
String markNeedsActionUrl(String id) =>
    '${baseUrl}api/orders/$id/mark-needs-action';
String requestRedeliveryUrl(String id) =>
    '${baseUrl}api/orders/$id/request-redelivery';
String retryDeliveryUrl(String id) => '${baseUrl}api/orders/$id/retry-delivery';

const String createOrderExchangeUrl =
    '${baseUrl}api/app/order-exchange/request';
const String getOrderExchangesUrl = '${baseUrl}api/app/order-exchange';
String getOrderExchangeUrl(String id) => '${baseUrl}api/app/order-exchange/$id';
String confirmOrderExchangeStockUrl(String id) =>
    '${baseUrl}api/app/order-exchange/$id/confirm-stock';
String swapOrderExchangeAtCustomerUrl(String id) =>
    '${baseUrl}api/app/order-exchange/$id/swap-at-customer';
String cancelOrderExchangeUrl(String id) =>
    '${baseUrl}api/app/order-exchange/$id/cancel';
String convertOrderExchangeToReturnUrl(String id) =>
    '${baseUrl}api/app/order-exchange/$id/convert-to-return';

/////// products (for Bakeet exchange replacement picking) ////////
const String getMyProductsForExchangeUrl = '${baseUrl}api/products/my-products';
String getProductVariantsForExchangeUrl(String productId) =>
    '${baseUrl}api/products/$productId/variants';
/////// region ////////
const getRegionsUrl = '${baseUrl}api/regions';

////address////
const getMerchantAddressesUrl = '${baseUrl}api/merchant-addresses/my-addresses';
const createMerchantAddressesUrl = '${baseUrl}api/merchant-addresses';
const updateMerchantAddressesUrl = '${baseUrl}api/merchant-addresses';
const deleteMerchantAddressesUrl = '${baseUrl}api/merchant-addresses';

/////// delivery ////////
const myDriverSettlementsUrl =
    '${baseUrl}api/settlement-requests/my-driver-assignments';

/////// delivery sessions ////////
const deliverySessionsUrl = '${baseUrl}api/delivery-session';
const createDeliverySessionUrl = '${baseUrl}api/delivery-session';
const addOrdersToSessionUrl = '${baseUrl}api/delivery-session';
const getActiveSessionUrl = '${baseUrl}api/delivery-session/driver';
const recordDeliveryUrl = '${baseUrl}api/delivery-session';
const completeSessionUrl = '${baseUrl}api/delivery-session';

String getDocumentUrlFunction(String masterType) {
  return "https://resident.api.jasim-erp.com/api/app/document/current_user?entityType=${EntityType.customer.toInt()}&masterType=$masterType";
}

//fright urls
// Create uses the same endpoint/contract as the successful web create flow
// (ShipmentBookingCreateCommand). The /from-mobile variant is intentionally NOT
// used; its only difference is that it does not accept `source`.
const String createShipmentBookingUrl =
    '${baseUrl}api/merchants/freight/shipment-booking';
const String getShipmentBookingListUrl =
    '${baseUrl}api/merchants/freight/shipment-booking';
String getShipmentBookingByIdUrl(String id) =>
    '${baseUrl}api/merchants/freight/shipment-booking/$id';
const String getUomListUrl = '${baseUrl}api/merchants/freight/uom/autocomplete';
const String getCategoryListUrl = '${baseUrl}api/merchants/freight/categories';
const String getTagListUrl = '${baseUrl}api/merchants/freight/tags';
const String getTrackingShipmentUrl =
    '${baseFrightUrl}api/freight/tracking-shipment/by-tracking-number';
const freightMerchantMyProfileUrl = '${baseUrl}api/merchants/my-profile';

const String getAgentListUrl =
    '${baseFrightUrl}api/freight/agents/autocomplete';
const String getOrganizationListUrl =
    '${baseFrightUrl}api/core/organization/autocomplete';
const String getAgentMarkListUrl =
    '${baseFrightUrl}api/freight/agents/agent-mark-autocomplete';
// const String getZoneListUrl = '${baseFrightUrl}api/merchants/freight/zone/autocomplete';

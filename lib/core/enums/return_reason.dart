enum ReturnReason {
  customerRefused(1, 'Customer Refused'),
  customerNotAvailable(2, 'Customer Not Available'),
  wrongAddress(3, 'Wrong Address'),
  damaged(4, 'Damaged'),
  customerCancelled(5, 'Customer Cancelled'),
  merchantRequested(6, 'Merchant Requested'),
  failedDeliveryAttempts(7, 'Failed Delivery Attempts'),
  other(99, 'Other');

  const ReturnReason(this.value, this.displayName);

  final int value;
  final String displayName;

  static ReturnReason fromValue(int value) {
    return ReturnReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReturnReason.other,
    );
  }

  static ReturnReason? fromValueOrNull(int? value) {
    if (value == null) return null;
    try {
      return ReturnReason.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

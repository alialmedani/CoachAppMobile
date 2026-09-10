enum PackageCondition {
  good(1, 'Good'),
  damaged(2, 'Damaged'),
  opened(3, 'Opened'),
  partiallyDamaged(4, 'Partially Damaged');

  const PackageCondition(this.value, this.displayName);

  final int value;
  final String displayName;

  static PackageCondition fromValue(int value) {
    return PackageCondition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PackageCondition.good,
    );
  }

  static PackageCondition? fromValueOrNull(int? value) {
    if (value == null) return null;
    try {
      return PackageCondition.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

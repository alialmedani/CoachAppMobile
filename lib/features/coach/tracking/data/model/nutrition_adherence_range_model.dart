/// F5/PD5: nutrition adherence aggregated over a date range (weekly view) for a
/// trainee — mirrors backend `NutritionAdherenceRangeDto`.
///
/// Consumption is summed across every log in `FromDate..ToDate` and compared to
/// the active plan's daily calorie target. [averageCaloriesPercent] averages
/// over the days actually logged (so occasional missed days don't drag it to 0),
/// while [daysLogged] vs [daysInRange] conveys coverage separately from quality.
/// [averageCaloriesPercent] / [targetCaloriesPerDay] are `null` when nothing is
/// logged or there is no active plan / target.
class NutritionAdherenceRangeModel {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int daysInRange;
  final int daysLogged;
  final bool hasActivePlan;
  final double consumedCaloriesTotal;
  final double? targetCaloriesPerDay;
  final double? averageCaloriesPercent;

  NutritionAdherenceRangeModel({
    this.fromDate,
    this.toDate,
    this.daysInRange = 0,
    this.daysLogged = 0,
    this.hasActivePlan = false,
    this.consumedCaloriesTotal = 0,
    this.targetCaloriesPerDay,
    this.averageCaloriesPercent,
  });

  factory NutritionAdherenceRangeModel.fromJson(Map<String, dynamic> json) {
    double d(String k) => (json[k] as num?)?.toDouble() ?? 0;
    double? dn(String k) => (json[k] as num?)?.toDouble();
    return NutritionAdherenceRangeModel(
      fromDate: json['fromDate'] != null
          ? DateTime.tryParse(json['fromDate'])
          : null,
      toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate']) : null,
      daysInRange: json['daysInRange'] ?? 0,
      daysLogged: json['daysLogged'] ?? 0,
      hasActivePlan: json['hasActivePlan'] ?? false,
      consumedCaloriesTotal: d('consumedCaloriesTotal'),
      targetCaloriesPerDay: dn('targetCaloriesPerDay'),
      averageCaloriesPercent: dn('averageCaloriesPercent'),
    );
  }
}

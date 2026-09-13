/// The trainee's nutrition adherence for a day (mirrors backend
/// `NutritionAdherenceDto`): consumed vs target macros plus the server-computed
/// percentages.
///
/// Percentages are **uncapped** (can exceed 100) and are `null` when there is
/// no active plan or the target is 0 — the UI caps any bar at 100% but labels
/// the true value. Always present on `MyTodayDto`, even with no plan/log.
class NutritionAdherenceModel {
  final DateTime? date;
  final bool hasActivePlan;
  final bool hasLog;
  final double consumedCalories;
  final double consumedProteinG;
  final double consumedCarbsG;
  final double consumedFatG;
  final double? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final double? caloriesPercent;
  final double? proteinPercent;
  final double? carbsPercent;
  final double? fatPercent;
  final double? overallPercent;

  NutritionAdherenceModel({
    this.date,
    this.hasActivePlan = false,
    this.hasLog = false,
    this.consumedCalories = 0,
    this.consumedProteinG = 0,
    this.consumedCarbsG = 0,
    this.consumedFatG = 0,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.caloriesPercent,
    this.proteinPercent,
    this.carbsPercent,
    this.fatPercent,
    this.overallPercent,
  });

  factory NutritionAdherenceModel.fromJson(Map<String, dynamic> json) {
    double d(String k) => (json[k] as num?)?.toDouble() ?? 0;
    double? dn(String k) => (json[k] as num?)?.toDouble();
    return NutritionAdherenceModel(
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      hasActivePlan: json['hasActivePlan'] ?? false,
      hasLog: json['hasLog'] ?? false,
      consumedCalories: d('consumedCalories'),
      consumedProteinG: d('consumedProteinG'),
      consumedCarbsG: d('consumedCarbsG'),
      consumedFatG: d('consumedFatG'),
      targetCalories: dn('targetCalories'),
      targetProteinG: dn('targetProteinG'),
      targetCarbsG: dn('targetCarbsG'),
      targetFatG: dn('targetFatG'),
      caloriesPercent: dn('caloriesPercent'),
      proteinPercent: dn('proteinPercent'),
      carbsPercent: dn('carbsPercent'),
      fatPercent: dn('fatPercent'),
      overallPercent: dn('overallPercent'),
    );
  }
}

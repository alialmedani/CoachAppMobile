import 'meal_model.dart';

/// A coach-authored nutrition plan for a trainee (mirrors backend
/// `NutritionPlanDto`).
///
/// The list endpoint returns **summaries with an empty [meals] list**; the
/// single-get / create / update / set-active endpoints return the full tree
/// (meals → items, with `foodName`/`servingUnit` enriched and macros computed).
///
/// The optional target fields are coach-set daily targets — `null` when unset,
/// in which case the plan's [totalCalories] etc. act as the effective targets.
/// The `total*` fields are **read-only server totals** summed from all items;
/// they are authoritative and should be preferred over any client estimate.
class NutritionPlanModel {
  final String? id;
  final String? traineeId;
  final String? name;
  final String? description;
  final bool isActive;
  final double? targetCalories;
  final double? targetProteinG;
  final double? targetCarbsG;
  final double? targetFatG;
  final List<MealModel> meals;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final DateTime? creationTime;

  NutritionPlanModel({
    this.id,
    this.traineeId,
    this.name,
    this.description,
    this.isActive = false,
    this.targetCalories,
    this.targetProteinG,
    this.targetCarbsG,
    this.targetFatG,
    this.meals = const [],
    this.totalCalories = 0,
    this.totalProteinG = 0,
    this.totalCarbsG = 0,
    this.totalFatG = 0,
    this.creationTime,
  });

  /// Total meals (0 for list summaries, which don't load meals).
  int get mealCount => meals.length;

  /// Whether any daily target has been set (drives the targets UI in the card
  /// and the macro summary).
  bool get hasTargets =>
      targetCalories != null ||
      targetProteinG != null ||
      targetCarbsG != null ||
      targetFatG != null;

  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'] as List<dynamic>? ?? [];
    return NutritionPlanModel(
      id: json['id']?.toString(),
      traineeId: json['traineeId']?.toString(),
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'] ?? false,
      targetCalories: (json['targetCalories'] as num?)?.toDouble(),
      targetProteinG: (json['targetProteinG'] as num?)?.toDouble(),
      targetCarbsG: (json['targetCarbsG'] as num?)?.toDouble(),
      targetFatG: (json['targetFatG'] as num?)?.toDouble(),
      meals: rawMeals.map((m) => MealModel.fromJson(m)).toList(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble() ?? 0,
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['totalFatG'] as num?)?.toDouble() ?? 0,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'traineeId': traineeId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'targetCalories': targetCalories,
      'targetProteinG': targetProteinG,
      'targetCarbsG': targetCarbsG,
      'targetFatG': targetFatG,
      'meals': meals.map((m) => m.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProteinG': totalProteinG,
      'totalCarbsG': totalCarbsG,
      'totalFatG': totalFatG,
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  NutritionPlanModel copyWith({
    String? id,
    String? traineeId,
    String? name,
    String? description,
    bool? isActive,
    double? targetCalories,
    double? targetProteinG,
    double? targetCarbsG,
    double? targetFatG,
    List<MealModel>? meals,
    double? totalCalories,
    double? totalProteinG,
    double? totalCarbsG,
    double? totalFatG,
    DateTime? creationTime,
  }) {
    return NutritionPlanModel(
      id: id ?? this.id,
      traineeId: traineeId ?? this.traineeId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProteinG: targetProteinG ?? this.targetProteinG,
      targetCarbsG: targetCarbsG ?? this.targetCarbsG,
      targetFatG: targetFatG ?? this.targetFatG,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteinG: totalProteinG ?? this.totalProteinG,
      totalCarbsG: totalCarbsG ?? this.totalCarbsG,
      totalFatG: totalFatG ?? this.totalFatG,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}

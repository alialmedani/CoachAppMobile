import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';

/// A trainee's logged nutrition day (mirrors backend `NutritionLogDto`).
///
/// Per-item macros and the `total*` fields are **server-computed / read-only**
/// (calories = food per-serving × quantity, summed for totals); the client
/// only ever sends `foodId`/`order`/`quantity`/`notes` on create/update.
class NutritionLogModel {
  final String? id;
  final String? traineeId;
  final String? nutritionPlanId;
  final DateTime? date;
  final String? notes;
  final List<NutritionLogEntryModel> entries;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;

  NutritionLogModel({
    this.id,
    this.traineeId,
    this.nutritionPlanId,
    this.date,
    this.notes,
    this.entries = const [],
    this.totalCalories = 0,
    this.totalProteinG = 0,
    this.totalCarbsG = 0,
    this.totalFatG = 0,
  });

  factory NutritionLogModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'] as List<dynamic>? ?? [];
    return NutritionLogModel(
      id: json['id']?.toString(),
      traineeId: json['traineeId']?.toString(),
      nutritionPlanId: json['nutritionPlanId']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      notes: json['notes'],
      entries: rawEntries
          .map(
            (e) => NutritionLogEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble() ?? 0,
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['totalFatG'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Builds an **unsaved** draft log from a nutrition [plan] by flattening its
  /// meals → items into log entries (same shape the `from-plan` endpoint
  /// produces). Lets the log editor open and adjust quantities WITHOUT creating
  /// anything server-side — the log is POSTed (from-plan) only on Save, so
  /// backing out leaves no phantom log.
  factory NutritionLogModel.draftFromPlan(NutritionPlanModel plan) {
    final entries = <NutritionLogEntryModel>[];
    var order = 0;
    for (final meal in plan.meals) {
      for (final item in meal.items) {
        entries.add(
          NutritionLogEntryModel(
            foodId: item.foodId,
            foodName: item.foodName,
            servingUnit: item.servingUnit,
            servingSize: item.servingSize,
            quantity: item.quantity,
            order: order++,
            calories: item.calories,
            proteinG: item.proteinG,
            carbsG: item.carbsG,
            fatG: item.fatG,
          ),
        );
      }
    }
    return NutritionLogModel(nutritionPlanId: plan.id, entries: entries);
  }
}

/// One logged food item inside a [NutritionLogModel] (mirrors backend
/// `NutritionLogEntryDto`).
class NutritionLogEntryModel {
  final String? id;
  final String? foodId;
  final String? foodName;
  final String? servingUnit;

  /// Grams (or [servingUnit]s) in one serving of the food, e.g. 100. [quantity]
  /// is the number of servings, so the real amount is `quantity × servingSize`.
  final double servingSize;
  final double quantity;
  final int order;
  final String? notes;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  NutritionLogEntryModel({
    this.id,
    this.foodId,
    this.foodName,
    this.servingUnit,
    this.servingSize = 0,
    this.quantity = 1,
    this.order = 0,
    this.notes,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  factory NutritionLogEntryModel.fromJson(Map<String, dynamic> json) {
    return NutritionLogEntryModel(
      id: json['id']?.toString(),
      foodId: json['foodId']?.toString(),
      foodName: json['foodName'],
      servingUnit: json['servingUnit'],
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      order: json['order'] ?? 0,
      notes: json['notes'],
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Write shape for `CreateNutritionLogEntryDto` (create & update reuse it).
  /// Macros are excluded — the server computes them.
  Map<String, dynamic> toWriteJson() {
    return {
      'foodId': foodId,
      'order': order,
      'quantity': quantity,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  NutritionLogEntryModel copyWith({double? quantity, String? notes}) {
    return NutritionLogEntryModel(
      id: id,
      foodId: foodId,
      foodName: foodName,
      servingUnit: servingUnit,
      servingSize: servingSize,
      quantity: quantity ?? this.quantity,
      order: order,
      notes: notes ?? this.notes,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
    );
  }
}

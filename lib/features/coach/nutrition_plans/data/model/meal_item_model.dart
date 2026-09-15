import '../../../foods/data/model/food_model.dart';

/// A single food entry inside a meal (mirrors backend `MealItemDto`).
///
/// [foodName], [servingUnit] and [servingSize] are read-only display data
/// enriched by the server from the food library; they are never sent back on
/// write. [quantity] is the **number of servings** — the real amount the trainee
/// eats is `quantity × servingSize servingUnit` (e.g. 2 × 100 g = 200 g). The
/// macro fields ([calories]/[proteinG]/[carbsG]/[fatG]) are **read-only computed
/// values** (food per-serving × [quantity]); the server recomputes them on save,
/// so they are excluded from [toWriteJson]. Decimals are parsed via
/// `(num?)?.toDouble()`.
class MealItemModel {
  final String? id;
  final String? foodId;
  final String? foodName;
  final String? servingUnit;

  /// Grams (or [servingUnit]s) in one serving of the food, e.g. 100. The real
  /// amount for this item is `quantity × servingSize`.
  final double servingSize;
  final double quantity;
  final int order;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  MealItemModel({
    this.id,
    this.foodId,
    this.foodName,
    this.servingUnit,
    this.servingSize = 0,
    this.quantity = 1,
    this.order = 0,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['id']?.toString(),
      foodId: json['foodId']?.toString(),
      foodName: json['foodName'],
      servingUnit: json['servingUnit'],
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      order: json['order'] ?? 0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Builds a local item from a picked [FoodModel] and a serving [quantity],
  /// computing the display macros client-side (food per-serving × [quantity]).
  /// These are estimates until the server returns the authoritative totals.
  factory MealItemModel.fromFood(
    FoodModel food,
    double quantity, {
    String? id,
    int order = 0,
  }) {
    return MealItemModel(
      id: id,
      foodId: food.id,
      foodName: food.name,
      servingUnit: food.servingUnit,
      servingSize: food.servingSize,
      quantity: quantity,
      order: order,
      calories: food.calories * quantity,
      proteinG: food.proteinG * quantity,
      carbsG: food.carbsG * quantity,
      fatG: food.fatG * quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'servingUnit': servingUnit,
      'servingSize': servingSize,
      'quantity': quantity,
      'order': order,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
    };
  }

  /// Write shape for `CreateUpdateMealItemDto` — only `foodId`, `order` and
  /// `quantity`; no child `id`, no enriched names, no computed macros (the
  /// server recomputes them). [order] is taken from the list position.
  Map<String, dynamic> toWriteJson(int order) {
    return {'foodId': foodId, 'order': order, 'quantity': quantity};
  }

  MealItemModel copyWith({
    String? id,
    String? foodId,
    String? foodName,
    String? servingUnit,
    double? servingSize,
    double? quantity,
    int? order,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) {
    return MealItemModel(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      servingUnit: servingUnit ?? this.servingUnit,
      servingSize: servingSize ?? this.servingSize,
      quantity: quantity ?? this.quantity,
      order: order ?? this.order,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }
}

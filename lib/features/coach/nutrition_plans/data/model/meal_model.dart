import 'meal_item_model.dart';

/// A meal inside a nutrition plan (mirrors backend `MealDto`).
///
/// [order] is the meal's position within the plan. [items] carries the food
/// entries (with enriched names + computed macros on read).
class MealModel {
  final String? id;
  final String name;
  final int order;
  final List<MealItemModel> items;

  MealModel({
    this.id,
    this.name = '',
    this.order = 0,
    this.items = const [],
  });

  /// Sum of this meal's item calories (client-side estimate from read/computed
  /// values). Used for the meal-level macro estimate in the builder.
  double get totalCalories =>
      items.fold(0.0, (sum, i) => sum + i.calories);
  double get totalProteinG =>
      items.fold(0.0, (sum, i) => sum + i.proteinG);
  double get totalCarbsG => items.fold(0.0, (sum, i) => sum + i.carbsG);
  double get totalFatG => items.fold(0.0, (sum, i) => sum + i.fatG);

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return MealModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      items: rawItems.map((e) => MealItemModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  /// Write shape for `CreateUpdateMealDto` — no child `id`; [order] is taken
  /// from the list position and items are re-indexed by position.
  Map<String, dynamic> toWriteJson(int order) {
    return {
      'name': name,
      'order': order,
      'items': [
        for (var i = 0; i < items.length; i++) items[i].toWriteJson(i),
      ],
    };
  }

  MealModel copyWith({
    String? id,
    String? name,
    int? order,
    List<MealItemModel>? items,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      items: items ?? this.items,
    );
  }
}

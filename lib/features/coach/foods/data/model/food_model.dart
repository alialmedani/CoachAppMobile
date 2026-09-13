/// A coach's food library item (mirrors backend `FoodDto`). All nutrition
/// values are per [servingSize] [servingUnit].
class FoodModel {
  final String? id;
  final String? name;
  final String? description;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool isActive;
  final DateTime? creationTime;

  FoodModel({
    this.id,
    this.name,
    this.description,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.isActive = true,
    this.creationTime,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      servingSize: (json['servingSize'] as num?)?.toDouble() ?? 100,
      servingUnit: json['servingUnit'] ?? 'g',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] ?? true,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'calories': calories,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'isActive': isActive,
      'creationTime': creationTime?.toIso8601String(),
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    double? servingSize,
    String? servingUnit,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    bool? isActive,
    DateTime? creationTime,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      isActive: isActive ?? this.isActive,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}

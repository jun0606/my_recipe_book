// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 3;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      title: fields[0] as String,
      ingredients: (fields[1] as List).cast<Ingredient>(),
      processes: (fields[2] as List).cast<String>(),
      category: fields[3] as RecipeCategory,
      description: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      mixingSteps: (fields[7] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      fermentationSteps: (fields[8] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      ovenSteps: (fields[9] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.ingredients)
      ..writeByte(2)
      ..write(obj.processes)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.mixingSteps)
      ..writeByte(8)
      ..write(obj.fermentationSteps)
      ..writeByte(9)
      ..write(obj.ovenSteps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeCategoryAdapter extends TypeAdapter<RecipeCategory> {
  @override
  final int typeId = 5;

  @override
  RecipeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecipeCategory.bread;
      case 1:
        return RecipeCategory.cake;
      case 2:
        return RecipeCategory.cookie;
      case 3:
        return RecipeCategory.dessert;
      default:
        return RecipeCategory.bread;
    }
  }

  @override
  void write(BinaryWriter writer, RecipeCategory obj) {
    switch (obj) {
      case RecipeCategory.bread:
        writer.writeByte(0);
        break;
      case RecipeCategory.cake:
        writer.writeByte(1);
        break;
      case RecipeCategory.cookie:
        writer.writeByte(2);
        break;
      case RecipeCategory.dessert:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      processes:
          (json['processes'] as List<dynamic>).map((e) => e as String).toList(),
      category: $enumDecode(_$RecipeCategoryEnumMap, json['category']),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      mixingSteps: (json['mixingSteps'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      fermentationSteps: (json['fermentationSteps'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      ovenSteps: (json['ovenSteps'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'title': instance.title,
      'ingredients': instance.ingredients,
      'processes': instance.processes,
      'category': _$RecipeCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'mixingSteps': instance.mixingSteps,
      'fermentationSteps': instance.fermentationSteps,
      'ovenSteps': instance.ovenSteps,
    };

const _$RecipeCategoryEnumMap = {
  RecipeCategory.bread: 'bread',
  RecipeCategory.cake: 'cake',
  RecipeCategory.cookie: 'cookie',
  RecipeCategory.dessert: 'dessert',
};

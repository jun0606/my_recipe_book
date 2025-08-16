// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sous_chef_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SousChefPresetAdapter extends TypeAdapter<SousChefPreset> {
  @override
  final int typeId = 1;

  @override
  SousChefPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SousChefPreset(
      id: fields[0] as String,
      name: fields[1] as String,
      colorTag: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      options: (fields[4] as Map).cast<String, dynamic>(),
      createdAt: fields[5] as DateTime,
      usageCount: fields[6] as int,
      successRate: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SousChefPreset obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorTag)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.options)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.usageCount)
      ..writeByte(7)
      ..write(obj.successRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SousChefPresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SousChefRecipeStateAdapter extends TypeAdapter<SousChefRecipeState> {
  @override
  final int typeId = 2;

  @override
  SousChefRecipeState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SousChefRecipeState(
      recipeId: fields[0] as String,
      bakingType: fields[1] as BakingType,
      activePresetId: fields[2] as String?,
      presets: (fields[3] as List).cast<SousChefPreset>(),
      currentAdjustments: (fields[4] as Map).cast<String, double>(),
      adjustmentHistory: (fields[5] as List).cast<AdjustmentHistoryEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, SousChefRecipeState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.recipeId)
      ..writeByte(1)
      ..write(obj.bakingType)
      ..writeByte(2)
      ..write(obj.activePresetId)
      ..writeByte(3)
      ..write(obj.presets)
      ..writeByte(4)
      ..write(obj.currentAdjustments)
      ..writeByte(5)
      ..write(obj.adjustmentHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SousChefRecipeStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdjustmentHistoryEntryAdapter
    extends TypeAdapter<AdjustmentHistoryEntry> {
  @override
  final int typeId = 3;

  @override
  AdjustmentHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdjustmentHistoryEntry(
      timestamp: fields[0] as DateTime,
      presetIdUsed: fields[1] as String,
      finalAdjustments: (fields[2] as Map).cast<String, double>(),
      userFeedback: fields[3] as UserFeedback?,
    );
  }

  @override
  void write(BinaryWriter writer, AdjustmentHistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.presetIdUsed)
      ..writeByte(2)
      ..write(obj.finalAdjustments)
      ..writeByte(3)
      ..write(obj.userFeedback);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdjustmentHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserFeedbackAdapter extends TypeAdapter<UserFeedback> {
  @override
  final int typeId = 4;

  @override
  UserFeedback read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserFeedback(
      result: fields[0] as FeedbackResult,
      memo: fields[1] as String,
      imagePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserFeedback obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.result)
      ..writeByte(1)
      ..write(obj.memo)
      ..writeByte(2)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFeedbackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BakingTypeAdapter extends TypeAdapter<BakingType> {
  @override
  final int typeId = 0;

  @override
  BakingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BakingType.bread;
      case 1:
        return BakingType.cake;
      case 2:
        return BakingType.cookie;
      case 3:
        return BakingType.fried;
      case 4:
        return BakingType.dessertHot;
      case 5:
        return BakingType.dessertCold;
      case 6:
        return BakingType.frozenDessert;
      case 7:
        return BakingType.iceCream;
      case 8:
        return BakingType.gelato;
      case 9:
        return BakingType.candy;
      case 10:
        return BakingType.etc;
      default:
        return BakingType.bread;
    }
  }

  @override
  void write(BinaryWriter writer, BakingType obj) {
    switch (obj) {
      case BakingType.bread:
        writer.writeByte(0);
        break;
      case BakingType.cake:
        writer.writeByte(1);
        break;
      case BakingType.cookie:
        writer.writeByte(2);
        break;
      case BakingType.fried:
        writer.writeByte(3);
        break;
      case BakingType.dessertHot:
        writer.writeByte(4);
        break;
      case BakingType.dessertCold:
        writer.writeByte(5);
        break;
      case BakingType.frozenDessert:
        writer.writeByte(6);
        break;
      case BakingType.iceCream:
        writer.writeByte(7);
        break;
      case BakingType.gelato:
        writer.writeByte(8);
        break;
      case BakingType.candy:
        writer.writeByte(9);
        break;
      case BakingType.etc:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BakingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FeedbackResultAdapter extends TypeAdapter<FeedbackResult> {
  @override
  final int typeId = 5;

  @override
  FeedbackResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FeedbackResult.success;
      case 1:
        return FeedbackResult.failure;
      case 2:
        return FeedbackResult.partialSuccess;
      default:
        return FeedbackResult.success;
    }
  }

  @override
  void write(BinaryWriter writer, FeedbackResult obj) {
    switch (obj) {
      case FeedbackResult.success:
        writer.writeByte(0);
        break;
      case FeedbackResult.failure:
        writer.writeByte(1);
        break;
      case FeedbackResult.partialSuccess:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

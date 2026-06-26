import 'dart:convert';
import '../../domain/entities/finance_entities.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (t) => t.name == (json['type'] as String),
        orElse: () => TransactionType.expense,
      ),
      category: json['category'] as String? ?? 'Lainnya',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      createdAt: entity.createdAt,
    );
  }

  static String encodeList(List<TransactionModel> items) {
    return jsonEncode(items.map((t) => t.toJson()).toList());
  }

  static List<TransactionModel> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class GoalAllocationModel extends GoalAllocationEntity {
  const GoalAllocationModel({
    required super.name,
    required super.allocatedAmount,
  });

  factory GoalAllocationModel.fromJson(Map<String, dynamic> json) {
    return GoalAllocationModel(
      name: json['name'] as String,
      allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'allocatedAmount': allocatedAmount,
    };
  }

  factory GoalAllocationModel.fromEntity(GoalAllocationEntity entity) {
    return GoalAllocationModel(
      name: entity.name,
      allocatedAmount: entity.allocatedAmount,
    );
  }
}

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    super.savedAmount,
    super.dailySaveAmount,
    super.monthlyTimeframeMonths,
    super.allocations,
    required super.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final rawAllocations = json['allocations'] as List<dynamic>? ?? [];
    return GoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num? ?? 0.0).toDouble(),
      dailySaveAmount: json['dailySaveAmount'] != null ? (json['dailySaveAmount'] as num).toDouble() : null,
      monthlyTimeframeMonths: json['monthlyTimeframeMonths'] as int?,
      allocations: rawAllocations.map((e) => GoalAllocationModel.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'dailySaveAmount': dailySaveAmount,
      'monthlyTimeframeMonths': monthlyTimeframeMonths,
      'allocations': allocations.map((e) => GoalAllocationModel.fromEntity(e).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      savedAmount: entity.savedAmount,
      dailySaveAmount: entity.dailySaveAmount,
      monthlyTimeframeMonths: entity.monthlyTimeframeMonths,
      allocations: entity.allocations,
      createdAt: entity.createdAt,
    );
  }

  static String encodeList(List<GoalModel> items) {
    return jsonEncode(items.map((g) => g.toJson()).toList());
  }

  static List<GoalModel> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) => GoalModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

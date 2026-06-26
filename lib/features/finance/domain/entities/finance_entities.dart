import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category; // e.g. 'Transfer', 'Belanja', 'Transportasi', 'Uang masuk', 'Lainnya'
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAt,
  });

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, type, category, createdAt];
}

class GoalAllocationEntity extends Equatable {
  final String name;
  final double allocatedAmount;

  const GoalAllocationEntity({
    required this.name,
    required this.allocatedAmount,
  });

  GoalAllocationEntity copyWith({
    String? name,
    double? allocatedAmount,
  }) {
    return GoalAllocationEntity(
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }

  @override
  List<Object?> get props => [name, allocatedAmount];
}

class GoalEntity extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final double? dailySaveAmount;
  final int? monthlyTimeframeMonths;
  final List<GoalAllocationEntity> allocations;
  final DateTime createdAt;

  const GoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.dailySaveAmount,
    this.monthlyTimeframeMonths,
    this.allocations = const [],
    required this.createdAt,
  });

  double get totalAllocated {
    return allocations.fold(0.0, (sum, item) => sum + item.allocatedAmount);
  }

  double get unallocatedAmount {
    return targetAmount - totalAllocated;
  }

  GoalEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    double? dailySaveAmount,
    int? monthlyTimeframeMonths,
    List<GoalAllocationEntity>? allocations,
    DateTime? createdAt,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      dailySaveAmount: dailySaveAmount ?? this.dailySaveAmount,
      monthlyTimeframeMonths: monthlyTimeframeMonths ?? this.monthlyTimeframeMonths,
      allocations: allocations ?? this.allocations,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        savedAmount,
        dailySaveAmount,
        monthlyTimeframeMonths,
        allocations,
        createdAt,
      ];
}

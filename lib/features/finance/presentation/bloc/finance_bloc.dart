import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/finance_repository.dart';

// ─── Events ───
abstract class FinanceEvent extends Equatable {
  const FinanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadFinanceData extends FinanceEvent {}

class AddTransactionEvent extends FinanceEvent {
  final TransactionEntity transaction;
  const AddTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends FinanceEvent {
  final TransactionEntity transaction;
  const UpdateTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends FinanceEvent {
  final String id;
  const DeleteTransactionEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class AddGoalEvent extends FinanceEvent {
  final GoalEntity goal;
  const AddGoalEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class UpdateGoalEvent extends FinanceEvent {
  final GoalEntity goal;
  const UpdateGoalEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class DeleteGoalEvent extends FinanceEvent {
  final String id;
  const DeleteGoalEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// ─── States ───
abstract class FinanceState extends Equatable {
  const FinanceState();
  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<TransactionEntity> transactions;
  final List<GoalEntity> goals;

  const FinanceLoaded({
    required this.transactions,
    required this.goals,
  });

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, double> get incomeByCategory {
    final map = <String, double>{};
    for (final tx in transactions.where((t) => t.type == TransactionType.income)) {
      map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
    }
    return map;
  }

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final tx in transactions.where((t) => t.type == TransactionType.expense)) {
      map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
    }
    return map;
  }

  @override
  List<Object?> get props => [transactions, goals];
}

class FinanceError extends FinanceState {
  final String message;
  const FinanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Bloc ───
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository repository;

  FinanceBloc({required this.repository}) : super(FinanceInitial()) {
    on<LoadFinanceData>(_onLoadData);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<AddGoalEvent>(_onAddGoal);
    on<UpdateGoalEvent>(_onUpdateGoal);
    on<DeleteGoalEvent>(_onDeleteGoal);
  }

  Future<void> _onLoadData(LoadFinanceData event, Emitter<FinanceState> emit) async {
    emit(FinanceLoading());
    try {
      final transactions = await repository.getAllTransactions();
      final goals = await repository.getAllGoals();
      emit(FinanceLoaded(transactions: transactions, goals: goals));
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addTransaction(event.transaction);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(UpdateTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateTransaction(event.transaction);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteTransaction(event.id);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onAddGoal(AddGoalEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.addGoal(event.goal);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoalEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.updateGoal(event.goal);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(DeleteGoalEvent event, Emitter<FinanceState> emit) async {
    try {
      await repository.deleteGoal(event.id);
      add(LoadFinanceData());
    } catch (e) {
      emit(FinanceError(e.toString()));
    }
  }
}

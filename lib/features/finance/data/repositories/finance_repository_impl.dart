import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_local_datasource.dart';
import '../models/finance_models.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceLocalDataSource _localDataSource;

  FinanceRepositoryImpl(this._localDataSource);

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    return await _localDataSource.getAllTransactions();
  }

  @override
  Future<void> addTransaction(TransactionEntity item) async {
    await _localDataSource.addTransaction(TransactionModel.fromEntity(item));
  }

  @override
  Future<void> updateTransaction(TransactionEntity item) async {
    await _localDataSource.updateTransaction(TransactionModel.fromEntity(item));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _localDataSource.deleteTransaction(id);
  }

  @override
  Future<List<GoalEntity>> getAllGoals() async {
    return await _localDataSource.getAllGoals();
  }

  @override
  Future<void> addGoal(GoalEntity item) async {
    await _localDataSource.addGoal(GoalModel.fromEntity(item));
  }

  @override
  Future<void> updateGoal(GoalEntity item) async {
    await _localDataSource.updateGoal(GoalModel.fromEntity(item));
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _localDataSource.deleteGoal(id);
  }
}

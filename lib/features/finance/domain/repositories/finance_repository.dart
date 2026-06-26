import '../entities/finance_entities.dart';

abstract class FinanceRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<void> addTransaction(TransactionEntity item);
  Future<void> updateTransaction(TransactionEntity item);
  Future<void> deleteTransaction(String id);

  Future<List<GoalEntity>> getAllGoals();
  Future<void> addGoal(GoalEntity item);
  Future<void> updateGoal(GoalEntity item);
  Future<void> deleteGoal(String id);
}

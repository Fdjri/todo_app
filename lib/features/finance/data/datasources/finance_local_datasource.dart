import 'package:shared_preferences/shared_preferences.dart';
import '../models/finance_models.dart';

class FinanceLocalDataSource {
  static const String _transactionsKey = 'finance_transactions_data';
  static const String _goalsKey = 'finance_goals_data';
  final SharedPreferences _prefs;

  FinanceLocalDataSource(this._prefs);

  // ─── Transactions ───
  Future<List<TransactionModel>> getAllTransactions() async {
    final jsonStr = _prefs.getString(_transactionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = TransactionModel.decodeList(jsonStr);
      // Sort newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<TransactionModel> items) async {
    await _prefs.setString(_transactionsKey, TransactionModel.encodeList(items));
  }

  Future<void> addTransaction(TransactionModel item) async {
    final list = await getAllTransactions();
    list.add(item);
    await saveTransactions(list);
  }

  Future<void> updateTransaction(TransactionModel item) async {
    final list = await getAllTransactions();
    final index = list.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      list[index] = item;
      await saveTransactions(list);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final list = await getAllTransactions();
    list.removeWhere((t) => t.id == id);
    await saveTransactions(list);
  }

  // ─── Goals ───
  Future<List<GoalModel>> getAllGoals() async {
    final jsonStr = _prefs.getString(_goalsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = GoalModel.decodeList(jsonStr);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGoals(List<GoalModel> items) async {
    await _prefs.setString(_goalsKey, GoalModel.encodeList(items));
  }

  Future<void> addGoal(GoalModel item) async {
    final list = await getAllGoals();
    list.add(item);
    await saveGoals(list);
  }

  Future<void> updateGoal(GoalModel item) async {
    final list = await getAllGoals();
    final index = list.indexWhere((g) => g.id == item.id);
    if (index != -1) {
      list[index] = item;
      await saveGoals(list);
    }
  }

  Future<void> deleteGoal(String id) async {
    final list = await getAllGoals();
    list.removeWhere((g) => g.id == id);
    await saveGoals(list);
  }
}

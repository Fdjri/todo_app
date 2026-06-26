import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/bow_divider.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/finance_entities.dart';
import '../bloc/finance_bloc.dart';
import '../../../../core/services/alarm_service.dart';

/// Finance & Life Goals Feature Screen (Fully in English with shadcn Select component)
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransactionType _dashboardActiveToggle = TransactionType.expense;

  // Custom Rupiah Formatter
  String _formatRupiah(double val) {
    final isNegative = val < 0;
    final absoluteVal = val.abs();
    final string = absoluteVal.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = string.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(string[i]);
      count++;
    }
    final reversed = buffer.toString().split('').reversed.join('');
    return '${isNegative ? '-' : ''}Rp$reversed';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.colorScheme.onSurface;
    final textHint = theme.hintColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header & Coquette Title ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Column(
                children: [
                  Text(
                    'Finance & Goals',
                    style: AppTypography.h1(color: textPrimary).copyWith(
                      fontFamily: GoogleFonts.dancingScript().fontFamily,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: BowDivider(),
                  ),
                ],
              ),
            ),

            // ─── Tabs Toggle (Dashboard vs Life Goals) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.creamLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primary.withValues(alpha: 0.15)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: textHint,
                  labelStyle: AppTypography.small().copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: AppTypography.small(),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Dashboard'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.card_giftcard_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Life Goals'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Main Content ───
            Expanded(
              child: BlocBuilder<FinanceBloc, FinanceState>(
                builder: (context, state) {
                  if (state is FinanceLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: primary),
                    );
                  }

                  if (state is FinanceLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDashboardTab(context, state, isDark, primary, textPrimary, textHint),
                        _buildGoalsTab(context, state, isDark, primary, textPrimary, textHint),
                      ],
                    );
                  }

                  if (state is FinanceError) {
                    return Center(
                      child: Text(
                        'Failed to load financial records 🎀\n${state.message}',
                        style: AppTypography.body(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'finance_fab',
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddTransactionDialog(context);
          } else {
            _showAddGoalDialog(context);
          }
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primary,
                primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  // ─── DASHBOARD SUB-SCREEN ───
  Widget _buildDashboardTab(
    BuildContext context,
    FinanceLoaded state,
    bool isDark,
    Color primary,
    Color textPrimary,
    Color textHint,
  ) {
    final income = state.totalIncome;
    final expense = state.totalExpense;
    final net = state.netBalance;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      children: [
        // Total Incomes, Expenses, Net
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? themeSurfaceColor(context) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Comparison Row (Income vs Expense)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF2EC4B6), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Income', style: AppTypography.small(color: textHint)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(income),
                          style: AppTypography.h3(color: textPrimary).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 24, width: 1, color: primary.withValues(alpha: 0.2)),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE76F51), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Expense', style: AppTypography.small(color: textHint)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(expense),
                          style: AppTypography.h3(color: textPrimary).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Net Balance (Difference)
              Text(
                'Difference: ${_formatRupiah(net)}',
                style: AppTypography.bodyBold(
                  color: net >= 0 ? const Color(0xFF2EC4B6) : const Color(0xFFE76F51),
                ),
              ),
              const SizedBox(height: 18),

              // Comparative Bar Chart
              _buildBarChart(income, expense, primary),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Toggle Filters for Category Row
        Row(
          children: [
            Expanded(
              child: _buildToggleOption(
                label: 'Income',
                type: TransactionType.income,
                isActive: _dashboardActiveToggle == TransactionType.income,
                primary: primary,
                textPrimary: textPrimary,
                textHint: textHint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleOption(
                label: 'Expense',
                type: TransactionType.expense,
                isActive: _dashboardActiveToggle == TransactionType.expense,
                primary: primary,
                textPrimary: textPrimary,
                textHint: textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Categories List
        _buildCategoryBreakdown(context, state, primary, textPrimary, textHint, isDark),
      ],
    );
  }

  Widget _buildToggleOption({
    required String label,
    required TransactionType type,
    required bool isActive,
    required Color primary,
    required Color textPrimary,
    required Color textHint,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _dashboardActiveToggle = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (type == TransactionType.income ? const Color(0xFF2EC4B6).withValues(alpha: 0.15) : const Color(0xFFE76F51).withValues(alpha: 0.15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? (type == TransactionType.income ? const Color(0xFF2EC4B6) : const Color(0xFFE76F51))
                : primary.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.small(
              color: isActive
                  ? (type == TransactionType.income ? const Color(0xFF1E8276) : const Color(0xFFB0422B))
                  : textHint,
            ).copyWith(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(double income, double expense, Color primary) {
    const double maxHeight = 80.0;
    double maxVal = (income > expense ? income : expense);
    if (maxVal == 0) maxVal = 1;
    double incomeHeight = (income / maxVal) * maxHeight;
    double expenseHeight = (expense / maxVal) * maxHeight;

    // Minimum visual bounds
    if (incomeHeight < 8 && income > 0) incomeHeight = 8;
    if (expenseHeight < 8 && expense > 0) expenseHeight = 8;

    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Income Bar
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 64,
                height: incomeHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF2EC4B6),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2EC4B6).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text('Income', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          
          // Expense Bar
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 64,
                height: expenseHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFE76F51),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFE76F51).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text('Expense', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    FinanceLoaded state,
    Color primary,
    Color textPrimary,
    Color textHint,
    bool isDark,
  ) {
    final isIncome = _dashboardActiveToggle == TransactionType.income;
    final total = isIncome ? state.totalIncome : state.totalExpense;
    final rawBreakdown = isIncome ? state.incomeByCategory : state.expenseByCategory;

    if (rawBreakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text('🎀', style: TextStyle(fontSize: 28, color: primary)),
            const SizedBox(height: 8),
            Text(
              'No records for ${isIncome ? "Income" : "Expense"} yet.',
              style: AppTypography.caption(color: textHint),
            ),
          ],
        ),
      );
    }

    // Sort by amount descending
    final sortedCategories = rawBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, IconData> categoryIcons = {
      'Salary': Icons.payments_rounded,
      'Investment': Icons.trending_up_rounded,
      'Gift': Icons.card_giftcard_rounded,
      'Refund': Icons.swap_horiz_rounded,
      'Food & Dining': Icons.restaurant_rounded,
      'Shopping': Icons.shopping_bag_rounded,
      'Transportation': Icons.directions_car_rounded,
      'Entertainment': Icons.local_activity_rounded,
      'Bills & Utilities': Icons.receipt_long_rounded,
      'Others': Icons.category_rounded,
    };

    return Column(
      children: sortedCategories.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final percentage = total > 0 ? (amount / total) * 100 : 0.0;
        final icon = categoryIcons[category] ?? Icons.category_rounded;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? themeSurfaceColor(context) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.12)),
            ),
            child: ListTile(
              onTap: () => _showCategoryHistoryDrawer(context, category, _dashboardActiveToggle, state.transactions),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xFF2EC4B6).withValues(alpha: 0.1) : const Color(0xFFE76F51).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isIncome ? const Color(0xFF2EC4B6) : const Color(0xFFE76F51),
                  size: 20,
                ),
              ),
              title: Text(
                category,
                style: AppTypography.body(color: textPrimary).copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.small(color: textHint),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatRupiah(amount),
                    style: AppTypography.bodyBold(color: textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, color: textHint),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── CATEGORY HISTORY DETAILS DRAWER ───
  void _showCategoryHistoryDrawer(
    BuildContext context,
    String category,
    TransactionType type,
    List<TransactionEntity> allTransactions,
  ) {
    final filtered = allTransactions.where((t) => t.category == category && t.type == type).toList();
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    // Group by Date
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final tx in filtered) {
      final dateStr = _formatGroupDate(tx.createdAt);
      grouped.putIfAbsent(dateStr, () => []).add(tx);
    }

    shadcn.openDrawer(
      context: context,
      position: shadcn.OverlayPosition.bottom,
      builder: (drawerContext) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: theme.hintColor.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              category,
              style: AppTypography.h2(color: textPrimary).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${filtered.length} transactions in this category 🌸',
              style: AppTypography.small(color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            const BowDivider(),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: grouped.entries.map((entry) {
                  final date = entry.key;
                  final list = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          date,
                          style: AppTypography.small(color: primary).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...list.map((tx) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: primary.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: AppTypography.body(color: textPrimary).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${type == TransactionType.income ? "+" : "-"}${_formatRupiah(tx.amount)}',
                                  style: AppTypography.bodyBold(
                                    color: type == TransactionType.income ? const Color(0xFF2EC4B6) : const Color(0xFFE76F51),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                  onPressed: () {
                                    context.read<FinanceBloc>().add(DeleteTransactionEvent(tx.id));
                                    Navigator.of(drawerContext).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 24, thickness: 0.5),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGroupDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ─── LIFE GOALS SUB-SCREEN ───
  Widget _buildGoalsTab(
    BuildContext context,
    FinanceLoaded state,
    bool isDark,
    Color primary,
    Color textPrimary,
    Color textHint,
  ) {
    if (state.goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🧸', style: TextStyle(fontSize: 48, color: primary)),
              const SizedBox(height: 16),
              Text(
                'No Life Goals Saved Yet',
                style: AppTypography.h2(color: textPrimary).copyWith(
                  fontFamily: GoogleFonts.dancingScript().fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create a dream savings goal (e.g. Japan Trip 🎌) and calculate savings automatically. Tap the + below to start!',
                style: AppTypography.body(color: textHint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      itemCount: state.goals.length,
      itemBuilder: (context, index) {
        final goal = state.goals[index];
        return _buildGoalCard(context, goal, isDark, primary, textPrimary, textHint);
      },
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    GoalEntity goal,
    bool isDark,
    Color primary,
    Color textPrimary,
    Color textHint,
  ) {
    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
    
    // Dynamic Duration Calculators
    String calculationText = '';
    if (goal.dailySaveAmount != null && goal.dailySaveAmount! > 0) {
      final daysLeft = ((goal.targetAmount - goal.savedAmount) / goal.dailySaveAmount!).ceil();
      calculationText = 'Daily Saving: ${_formatRupiah(goal.dailySaveAmount!)} \n⏳ Target reached in $daysLeft days';
    } else if (goal.monthlyTimeframeMonths != null && goal.monthlyTimeframeMonths! > 0) {
      final monthlyNeeded = (goal.targetAmount - goal.savedAmount) / goal.monthlyTimeframeMonths!;
      calculationText = 'Timeframe: ${goal.monthlyTimeframeMonths} months \n📅 Monthly savings: ${_formatRupiah(monthlyNeeded)}/month';
    }

    return Padding(
      key: ValueKey(goal.id),
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? themeSurfaceColor(context) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          shape: const Border(),
          iconColor: primary,
          title: Text(
            goal.name,
            style: AppTypography.h3(color: textPrimary).copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                'Saved: ${_formatRupiah(goal.savedAmount)} / ${_formatRupiah(goal.targetAmount)}',
                style: AppTypography.small(color: textHint),
              ),
              const SizedBox(height: 8),
              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: primary.withValues(alpha: 0.1),
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Completed',
                style: AppTypography.small(color: primary).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, thickness: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calculation
                  if (calculationText.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        calculationText,
                        style: AppTypography.small(color: textPrimary).copyWith(height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Allocation Calculator Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Allocation Plan 🎌',
                        style: AppTypography.bodyBold(color: textPrimary),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                        label: const Text('Add Allocation'),
                        onPressed: () => _showAddAllocationDialog(context, goal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Allocation Progress
                  _buildAllocationProgress(goal, primary),
                  const SizedBox(height: 12),

                  // Allocation list
                  if (goal.allocations.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'No allocations yet. Allocate ${_formatRupiah(goal.targetAmount)} for your trip/needs! 🌸',
                          style: AppTypography.small(color: textHint),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...goal.allocations.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Text('🌸', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                style: AppTypography.small(color: textPrimary),
                              ),
                            ),
                            Text(
                              _formatRupiah(item.allocatedAmount),
                              style: AppTypography.small(color: textPrimary).copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 16, color: Colors.redAccent),
                              onPressed: () {
                                final updatedAllocations = List<GoalAllocationEntity>.from(goal.allocations)
                                  ..remove(item);
                                final updatedGoal = goal.copyWith(allocations: updatedAllocations);
                                context.read<FinanceBloc>().add(UpdateGoalEvent(updatedGoal));
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                  const Divider(height: 24, thickness: 0.5),

                  // Quick actions: Add Saved savings / Delete Goal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      shadcn.Button(
                        style: const shadcn.ButtonStyle.destructive(),
                        onPressed: () {
                          shadcn.showDialog(
                            context: context,
                            builder: (ctx) => shadcn.AlertDialog(
                              title: const Text('Delete Goal? 🎀'),
                              content: const Text('Are you sure you want to delete this dream target?'),
                              actions: [
                                shadcn.Button(
                                  style: const shadcn.ButtonStyle.ghost(),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                                shadcn.Button(
                                  style: const shadcn.ButtonStyle.destructive(),
                                  onPressed: () {
                                    context.read<FinanceBloc>().add(DeleteGoalEvent(goal.id));
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Delete Goal'),
                      ),
                      shadcn.Button(
                        style: const shadcn.ButtonStyle.primary(),
                        onPressed: () => _showAddSavingDialog(context, goal),
                        child: const Text('Add Savings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationProgress(GoalEntity goal, Color primary) {
    final allocated = goal.totalAllocated;
    final total = goal.targetAmount;
    final percentAllocated = total > 0 ? (allocated / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Allocated: ${_formatRupiah(allocated)} / ${_formatRupiah(total)}',
              style: AppTypography.small(color: primary).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              'Unallocated: ${_formatRupiah(goal.unallocatedAmount)}',
              style: AppTypography.small(color: themeAccentColor(primary)).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentAllocated,
            minHeight: 6,
            backgroundColor: primary.withValues(alpha: 0.1),
            color: const Color(0xFF2EC4B6),
          ),
        ),
      ],
    );
  }

  // ─── ADD TRANSACTION OVERLAY DIALOG ───
  void _showAddTransactionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    String selectedCategory = 'Shopping';

    shadcn.showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(dialogCtx);
            final textPrimary = theme.colorScheme.onSurface;

            final expenseCategories = ['Food & Dining', 'Shopping', 'Transportation', 'Entertainment', 'Bills & Utilities', 'Others'];
            final incomeCategories = ['Salary', 'Investment', 'Gift', 'Refund', 'Others'];
            final categories = selectedType == TransactionType.income ? incomeCategories : expenseCategories;

            if (!categories.contains(selectedCategory)) {
              selectedCategory = categories.first;
            }

            return shadcn.OverlayManagerLayer(
              popoverHandler: shadcn.OverlayHandler.popover,
              menuHandler: shadcn.OverlayHandler.popover,
              tooltipHandler: shadcn.OverlayHandler.popover,
              child: shadcn.AlertDialog(
                title: const Text('Record Transaction 🎀'),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type selector
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedType = TransactionType.income;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedType == TransactionType.income ? const Color(0xFF2EC4B6).withValues(alpha: 0.1) : Colors.transparent,
                                border: Border.all(color: selectedType == TransactionType.income ? const Color(0xFF2EC4B6) : theme.hintColor.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('Income', style: AppTypography.small(color: selectedType == TransactionType.income ? const Color(0xFF1E8276) : textPrimary)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedType = TransactionType.expense;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedType == TransactionType.expense ? const Color(0xFFE76F51).withValues(alpha: 0.1) : Colors.transparent,
                                border: Border.all(color: selectedType == TransactionType.expense ? const Color(0xFFE76F51) : theme.hintColor.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('Expense', style: AppTypography.small(color: selectedType == TransactionType.expense ? const Color(0xFFB0422B) : textPrimary)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    TextField(
                      controller: titleController,
                      style: AppTypography.body(color: textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Transaction description',
                        hintText: 'Buy pink boba 🩷',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Amount
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: AppTypography.body(color: textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Amount (Rupiah)',
                        hintText: '25000',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Select Dropdown (using shadcn.Select)
                    Row(
                      children: [
                        Text('Category:', style: AppTypography.small(color: textPrimary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: shadcn.Select<String>(
                            value: selectedCategory,
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() {
                                  selectedCategory = v;
                                });
                              }
                            },
                            popupWidthConstraint: shadcn.PopoverConstraint.flexible,
                            popupConstraints: const BoxConstraints(
                              minWidth: 160,
                              maxWidth: 240,
                            ),
                            itemBuilder: (context, val) {
                              return Text(val, style: AppTypography.body(color: textPrimary));
                            },
                            popup: (context) {
                              return shadcn.SelectPopup(
                                items: shadcn.SelectItemList(
                                  children: categories.map((cat) {
                                    return shadcn.SelectItemButton(
                                      value: cat,
                                      child: Text(cat, style: AppTypography.body(color: textPrimary)),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                shadcn.Button(
                  style: const shadcn.ButtonStyle.ghost(),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                shadcn.Button(
                  style: const shadcn.ButtonStyle.primary(),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;

                    if (title.isEmpty || amount <= 0) {
                      shadcn.showToast(
                        context: context,
                        builder: (ctx, _) => shadcn.SurfaceCard(
                          child: shadcn.Basic(
                            title: Text(
                              'Invalid data! 🌸',
                              style: AppTypography.bodyBold(color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        location: shadcn.ToastLocation.bottomCenter,
                      );
                      return;
                    }

                    final newTx = TransactionEntity(
                      id: IdGenerator.generate(),
                      title: title,
                      amount: amount,
                      type: selectedType,
                      category: selectedCategory,
                      createdAt: DateTime.now(),
                    );
                    context.read<FinanceBloc>().add(AddTransactionEvent(newTx));
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),);
          },
        );
      },
    );
  }

  // ─── ADD LIFE GOAL DIALOG ───
  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final calculatorInputController = TextEditingController();
    
    // Calculator Type: daily target vs monthly timeframe
    String calcType = 'daily'; // 'daily' or 'monthly'

    shadcn.showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(dialogCtx);
            final textPrimary = theme.colorScheme.onSurface;
            final primary = theme.colorScheme.primary;

            return shadcn.AlertDialog(
              title: const Text('New Life Goal 🧸'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        style: AppTypography.body(color: textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Goal Name',
                          hintText: 'Trip to Japan 🎌',
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.body(color: textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Target Savings (Rupiah)',
                          hintText: '2000000',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Calculator Toggle
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  calcType = 'daily';
                                  calculatorInputController.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: calcType == 'daily' ? primary.withValues(alpha: 0.15) : Colors.transparent,
                                  border: Border.all(color: calcType == 'daily' ? primary : theme.hintColor.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('Daily Saving', style: AppTypography.small(color: textPrimary)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  calcType = 'monthly';
                                  calculatorInputController.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: calcType == 'monthly' ? primary.withValues(alpha: 0.15) : Colors.transparent,
                                  border: Border.all(color: calcType == 'monthly' ? primary : theme.hintColor.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('Target Months', style: AppTypography.small(color: textPrimary)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: calculatorInputController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.body(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: calcType == 'daily' ? 'Daily Savings Target (Rp)' : 'Target Duration (Months)',
                          hintText: calcType == 'daily' ? '15000' : '6',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                shadcn.Button(
                  style: const shadcn.ButtonStyle.ghost(),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                shadcn.Button(
                  style: const shadcn.ButtonStyle.primary(),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final target = double.tryParse(targetController.text.trim()) ?? 0.0;
                    final calcInput = double.tryParse(calculatorInputController.text.trim()) ?? 0.0;

                    if (name.isEmpty || target <= 0) {
                      shadcn.showToast(
                        context: context,
                        builder: (ctx, _) => shadcn.SurfaceCard(
                          child: shadcn.Basic(
                            title: Text(
                              'Invalid data! 🌸',
                              style: AppTypography.bodyBold(color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                        location: shadcn.ToastLocation.bottomCenter,
                      );
                      return;
                    }

                    double? dailySave;
                    int? monthlyTimeframe;

                    if (calcType == 'daily' && calcInput > 0) {
                      dailySave = calcInput;
                    } else if (calcType == 'monthly' && calcInput > 0) {
                      monthlyTimeframe = calcInput.toInt();
                    }

                    final newGoal = GoalEntity(
                      id: IdGenerator.generate(),
                      name: name,
                      targetAmount: target,
                      savedAmount: 0.0,
                      dailySaveAmount: dailySave,
                      monthlyTimeframeMonths: monthlyTimeframe,
                      createdAt: DateTime.now(),
                      allocations: const [],
                    );
                    context.read<FinanceBloc>().add(AddGoalEvent(newGoal));
                    AlarmService().scheduleDailySavingsReminder();
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── ADD SAVED VALUE TO GOAL DIALOG ───
  void _showAddSavingDialog(BuildContext context, GoalEntity goal) {
    final savingController = TextEditingController();

    shadcn.showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final textPrimary = theme.colorScheme.onSurface;

        return shadcn.AlertDialog(
          title: const Text('Add Savings 🌸'),
          content: SizedBox(
            width: 300,
            child: TextField(
              controller: savingController,
              keyboardType: TextInputType.number,
              style: AppTypography.body(color: textPrimary),
              decoration: const InputDecoration(
                labelText: 'Amount to save (Rp)',
                hintText: '50000',
              ),
            ),
          ),
          actions: [
            shadcn.Button(
              style: const shadcn.ButtonStyle.ghost(),
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            shadcn.Button(
              style: const shadcn.ButtonStyle.primary(),
              onPressed: () {
                final saving = double.tryParse(savingController.text.trim()) ?? 0.0;
                if (saving <= 0) return;

                final updatedGoal = goal.copyWith(
                  savedAmount: goal.savedAmount + saving,
                );
                context.read<FinanceBloc>().add(UpdateGoalEvent(updatedGoal));
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ─── ADD BUDGET ALLOCATION DIALOG ───
  void _showAddAllocationDialog(BuildContext context, GoalEntity goal) {
    final allocationNameController = TextEditingController();
    final allocationAmountController = TextEditingController();

    shadcn.showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final textPrimary = theme.colorScheme.onSurface;

        return shadcn.AlertDialog(
          title: const Text('Budget Allocation Plan 🎌'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: allocationNameController,
                  style: AppTypography.body(color: textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Allocation Purpose',
                    hintText: 'Flight Ticket ✈️',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: allocationAmountController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.body(color: textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Allocation Amount (Rp)',
                    hintText: '850000',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            shadcn.Button(
              style: const shadcn.ButtonStyle.ghost(),
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            shadcn.Button(
              style: const shadcn.ButtonStyle.primary(),
              onPressed: () {
                final name = allocationNameController.text.trim();
                final amount = double.tryParse(allocationAmountController.text.trim()) ?? 0.0;

                if (name.isEmpty || amount <= 0) return;

                if (amount > goal.unallocatedAmount) {
                  shadcn.showToast(
                    context: context,
                    builder: (ctx, _) => shadcn.SurfaceCard(
                      child: shadcn.Basic(
                        title: Text(
                          'Allocation amount exceeds remaining budget! 🌸',
                          style: AppTypography.bodyBold(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                    location: shadcn.ToastLocation.bottomCenter,
                  );
                  return;
                }

                final newAlloc = GoalAllocationEntity(name: name, allocatedAmount: amount);
                final updatedList = List<GoalAllocationEntity>.from(goal.allocations)..add(newAlloc);
                final updatedGoal = goal.copyWith(allocations: updatedList);

                context.read<FinanceBloc>().add(UpdateGoalEvent(updatedGoal));
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ─── Theme helper helpers ───
  Color themeSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color themeAccentColor(Color primary) {
    return HSLColor.fromColor(primary).withLightness(0.55).toColor();
  }
}

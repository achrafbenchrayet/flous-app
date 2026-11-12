class BudgetModel {
  final String id;
  final String userId;
  final String? categoryId;
  final int amount;
  final String period;
  final String startDate;
  final String endDate;
  final String? categoryName;
  final String? categoryIcon;
  final int? categoryColor;
  final int spentAmount;

  const BudgetModel({
    required this.id, required this.userId, this.categoryId,
    required this.amount, required this.period, required this.startDate,
    required this.endDate, this.categoryName, this.categoryIcon,
    this.categoryColor, this.spentAmount = 0,
  });

  double get consumptionRatio => amount > 0 ? (spentAmount / amount) : 0.0;
  bool get isExceeded => spentAmount > amount;
  bool get isWarning => consumptionRatio >= 0.80 && !isExceeded;

  factory BudgetModel.fromMap(Map<String, dynamic> map, {int spent = 0}) => BudgetModel(
    id: map['id'] as String, userId: map['user_id'] as String,
    categoryId: map['category_id'] as String?, amount: map['amount'] as int,
    period: map['period'] as String, startDate: map['start_date'] as String,
    endDate: map['end_date'] as String, categoryName: map['category_name'] as String?,
    categoryIcon: map['category_icon'] as String?, categoryColor: map['category_color'] as int?,
    spentAmount: spent,
  );
}

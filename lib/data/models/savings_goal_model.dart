class SavingsGoalModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int targetAmount;
  final int currentAmount;
  final String startDate;
  final String? deadline;
  final String icon;
  final int color;
  final String status;

  const SavingsGoalModel({
    required this.id, required this.userId, required this.name,
    this.description, required this.targetAmount, required this.currentAmount,
    required this.startDate, this.deadline, required this.icon,
    required this.color, required this.status,
  });

  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  int get remainingAmount => (targetAmount - currentAmount).clamp(0, targetAmount);

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) => SavingsGoalModel(
    id: map['id'] as String, userId: map['user_id'] as String,
    name: map['name'] as String, description: map['description'] as String?,
    targetAmount: map['target_amount'] as int, currentAmount: map['current_amount'] as int,
    startDate: map['start_date'] as String, deadline: map['deadline'] as String?,
    icon: map['icon'] as String, color: map['color'] as int,
    status: map['status'] as String,
  );
}

class SavingsMovementModel {
  final String id;
  final String userId;
  final String goalId;
  final int amount;
  final String movementType;
  final String date;
  final String? description;

  const SavingsMovementModel({
    required this.id, required this.userId, required this.goalId,
    required this.amount, required this.movementType, required this.date,
    this.description,
  });

  factory SavingsMovementModel.fromMap(Map<String, dynamic> map) => SavingsMovementModel(
    id: map['id'] as String, userId: map['user_id'] as String,
    goalId: map['goal_id'] as String, amount: map['amount'] as int,
    movementType: map['movement_type'] as String, date: map['date'] as String,
    description: map['description'] as String?,
  );
}

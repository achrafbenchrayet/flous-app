class TransactionModel {
  final String id;
  final String userId;
  final String categoryId;
  final String type;
  final int amount;
  final String description;
  final String date;
  final String time;
  final String paymentMethod;
  final String? note;
  final String createdAt;
  final String? categoryName;
  final String? categoryIcon;
  final int? categoryColor;

  const TransactionModel({
    required this.id, required this.userId, required this.categoryId,
    required this.type, required this.amount, required this.description,
    required this.date, required this.time, required this.paymentMethod,
    this.note, required this.createdAt, this.categoryName,
    this.categoryIcon, this.categoryColor,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
    id: map['id'] as String, userId: map['user_id'] as String,
    categoryId: map['category_id'] as String, type: map['type'] as String,
    amount: map['amount'] as int, description: map['description'] as String,
    date: map['date'] as String, time: map['time'] as String,
    paymentMethod: map['payment_method'] as String, note: map['note'] as String?,
    createdAt: map['created_at'] as String, categoryName: map['category_name'] as String?,
    categoryIcon: map['category_icon'] as String?, categoryColor: map['category_color'] as int?,
  );
}

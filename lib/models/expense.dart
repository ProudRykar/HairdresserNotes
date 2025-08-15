//expense.dart

class Expense {
  final DateTime date;
  final double amount;
  final String description;

  Expense({
    required this.date,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
        'description': description,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0),
        description: json['description'] as String? ?? '',
      );
}
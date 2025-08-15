class RecipeEntry {
  final DateTime date;
  final List<String> recipes;
  final double earnings;

  RecipeEntry({
    required this.date,
    required this.recipes,
    this.earnings = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'recipes': recipes,
        'earnings': earnings,
      };

  factory RecipeEntry.fromJson(Map<String, dynamic> json) => RecipeEntry(
        date: DateTime.parse(json['date'] as String),
        recipes: List<String>.from(json['recipes'] as List<dynamic>? ?? []),
        earnings: (json['earnings'] is num ? (json['earnings'] as num).toDouble() : 0.0),
      );
}

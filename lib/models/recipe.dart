//recipe.dart

class Recipe {
  final DateTime time;
  final String clientName;
  final List<String> recipes;
  final double earnings;

  Recipe({
    required this.time,
    required this.clientName,
    required this.recipes,
    this.earnings = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'clientName': clientName,
        'recipes': recipes,
        'earnings': earnings,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        time: DateTime.parse(json['time'] as String),
        clientName: json['clientName'] as String? ?? '',
        recipes: List<String>.from(json['recipes'] as List<dynamic>? ?? []),
        earnings: (json['earnings'] is num ? (json['earnings'] as num).toDouble() : 0.0),
      );
}
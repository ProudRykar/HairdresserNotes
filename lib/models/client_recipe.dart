//clientRecipe.dart

import 'package:stylist_notebook/models/recipe_entry.dart';

class ClientRecipe {
  final String clientName;
  final List<RecipeEntry> entries;

  ClientRecipe({
    required this.clientName,
    required this.entries,
  });

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory ClientRecipe.fromJson(Map<String, dynamic> json) => ClientRecipe(
        clientName: json['clientName'] as String? ?? '',
        entries: (json['entries'] as List<dynamic>? ?? [])
            .map((e) => RecipeEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
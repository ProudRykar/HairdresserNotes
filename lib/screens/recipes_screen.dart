import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<ClientRecipe> clientRecipes = [];
  List<ClientRecipe> filteredRecipes = [];
  Map<int, bool> expandedStates = {};
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null).then((_) {
      loadRecipes();
    });
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredRecipes = clientRecipes;
        showSuggestions = false;
      } else {
        filteredRecipes = clientRecipes
            .where((client) =>
                client.clientName.toLowerCase().contains(query))
            .toList();
        showSuggestions = true;
      }
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/recipes.json');
  }

  Future<void> loadRecipes() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(contents);
        setState(() {
          clientRecipes = jsonData
              .map((e) => ClientRecipe.fromJson(e as Map<String, dynamic>))
              .toList();
          filteredRecipes = clientRecipes;
          expandedStates = {for (var i = 0; i < clientRecipes.length; i++) i: false};
        });
      } else {
        setState(() {
          clientRecipes = [];
          filteredRecipes = [];
          expandedStates = {};
        });
      }
    } catch (e) {
      setState(() {
        clientRecipes = [];
        filteredRecipes = [];
        expandedStates = {};
      });
    }
  }

  Future<void> saveRecipes() async {
    try {
      final file = await _localFile;
      await file.writeAsString(
          jsonEncode(clientRecipes.map((e) => e.toJson()).toList()));
    } catch (e) {
      // TODO: Replace with proper logging in production
    }
  }

  Future<void> addClientRecipe(ClientRecipe clientRecipe) async {
    setState(() {
      clientRecipes.add(clientRecipe);
      filteredRecipes = clientRecipes;
      expandedStates[clientRecipes.length - 1] = false;
    });
    await saveRecipes();
  }

  Future<void> updateClientRecipe(int index, ClientRecipe updatedRecipe) async {
    setState(() {
      clientRecipes[index] = updatedRecipe;
      filteredRecipes = clientRecipes;
    });
    await saveRecipes();
  }

  Future<void> deleteClientRecipe(int index) async {
    setState(() {
      clientRecipes.removeAt(index);
      filteredRecipes = clientRecipes;
      expandedStates.remove(index);
      final newExpandedStates = <int, bool>{};
      for (var i = 0; i < clientRecipes.length; i++) {
        newExpandedStates[i] = expandedStates[i + (i >= index ? 1 : 0)] ?? false;
      }
      expandedStates = newExpandedStates;
    });
    await saveRecipes();
  }

  Future<void> deleteRecipeEntry(int clientIndex, int entryIndex) async {
    setState(() {
      clientRecipes[clientIndex].entries.removeAt(entryIndex);
      if (clientRecipes[clientIndex].entries.isEmpty) {
        clientRecipes.removeAt(clientIndex);
        filteredRecipes = clientRecipes;
        expandedStates.remove(clientIndex);
        final newExpandedStates = <int, bool>{};
        for (var i = 0; i < clientRecipes.length; i++) {
          newExpandedStates[i] = expandedStates[i + (i >= clientIndex ? 1 : 0)] ?? false;
        }
        expandedStates = newExpandedStates;
      } else {
        filteredRecipes = clientRecipes;
      }
    });
    await saveRecipes();
  }

  void showRecipeDialog(BuildContext context,
      {ClientRecipe? clientRecipe, int? index, RecipeEntry? entryToEdit}) {
    TextEditingController clientNameController =
        TextEditingController(text: clientRecipe?.clientName ?? '');
    TextEditingController earningsController = TextEditingController(
        text: entryToEdit?.earnings.toString() ?? '');
    List<TextEditingController> recipeControllers =
        (entryToEdit?.recipes ?? [''])
            .map((r) => TextEditingController(text: r))
            .toList();
    DateTime selectedDate =
        entryToEdit?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(clientRecipe == null
                  ? 'Новый клиент'
                  : entryToEdit == null
                      ? 'Новая запись'
                      : 'Редактировать запись'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entryToEdit == null)
                        TextField(
                          controller: clientNameController,
                          decoration:
                              const InputDecoration(hintText: 'Введите имя клиента'),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: selectedDate,
                          use24hFormat: true,
                          onDateTimeChanged: (DateTime value) {
                            setDialogState(() {
                              selectedDate = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Рецепт:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...recipeControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        TextEditingController controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: TextField(
                            controller: controller,
                            decoration:
                                InputDecoration(hintText: 'Введите рецепт ${idx + 1}'),
                          ),
                        );
                      }),
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            recipeControllers.add(TextEditingController());
                          });
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.blue),
                            SizedBox(width: 4),
                            Text('Добавить рецепт',
                                style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: earningsController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: 'Введите сумму (₽)'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    if (clientNameController.text.isNotEmpty ||
                        entryToEdit != null) {
                      final newRecipes = recipeControllers
                          .map((c) => c.text)
                          .where((text) => text.isNotEmpty)
                          .toList();
                      final newEntry = RecipeEntry(
                        date: selectedDate,
                        recipes: newRecipes,
                        earnings: double.tryParse(
                                earningsController.text.replaceAll(',', '.')) ??
                            0.0,
                      );

                      if (clientRecipe == null) {
                        addClientRecipe(ClientRecipe(
                          clientName: clientNameController.text,
                          entries: [newEntry],
                        ));
                      } else if (entryToEdit == null) {
                        final updatedEntries = [
                          ...clientRecipe.entries,
                          newEntry
                        ];
                        updateClientRecipe(
                            index!,
                            ClientRecipe(
                              clientName: clientRecipe.clientName,
                              entries: updatedEntries,
                            ));
                      } else {
                        final updatedEntries = clientRecipe.entries
                            .asMap()
                            .entries
                            .map((e) =>
                                e.value == entryToEdit ? newEntry : e.value)
                            .toList();
                        updateClientRecipe(
                            index!,
                            ClientRecipe(
                              clientName: clientRecipe.clientName,
                              entries: updatedEntries,
                            ));
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Заполните имя клиента и рецепт')),
                      );
                    }
                  },
                  child: Text(
                      clientRecipe == null ? 'Добавить' : 'Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'ru');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепты'),
        backgroundColor: const Color.fromARGB(176, 94, 94, 253),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Поиск по имени клиента',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              _onSearchChanged();
                              searchFocusNode.requestFocus();
                            },
                          )
                        : null,
                  ),
                ),
                if (showSuggestions && searchController.text.isNotEmpty)
                  Positioned(
                    top: 56,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(filteredRecipes[index].clientName),
                              onTap: () {
                                searchController.text =
                                    filteredRecipes[index].clientName;
                                _onSearchChanged();
                                searchFocusNode.unfocus();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filteredRecipes.isEmpty
                ? const Center(child: Text('Нет рецептов'))
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final clientRecipe = filteredRecipes[index];
                      final clientIndex = clientRecipes.indexOf(clientRecipe);
                      final isExpanded = expandedStates[clientIndex] ?? false;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedStates[clientIndex] = !isExpanded;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        clientRecipe.clientName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded ? Icons.expand_less : Icons.expand_more,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpanded)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...clientRecipe.entries.asMap().entries.map((entry) {
                                      final entryIndex = entry.key;
                                      final recipeEntry = entry.value;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              showRecipeDialog(context,
                                                  clientRecipe: clientRecipe,
                                                  index: clientIndex,
                                                  entryToEdit: recipeEntry);
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Дата: ${dateFormat.format(recipeEntry.date)}',
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w500),
                                                ),
                                                const Text('Рецепт:',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500)),
                                                ...recipeEntry.recipes
                                                    .asMap()
                                                    .entries
                                                    .map((recipe) {
                                                  return Text(
                                                      '${recipe.key + 1}. ${recipe.value}');
                                                }),
                                                if (recipeEntry.earnings > 0)
                                                  Text(
                                                    'Заработано: ${recipeEntry.earnings.toStringAsFixed(2)} ₽',
                                                    style:
                                                        const TextStyle(color: Colors.green),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Удалить запись?'),
                                                      content: const Text(
                                                          'Вы уверены, что хотите удалить эту запись?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(context),
                                                          child: const Text('Отмена'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            deleteRecipeEntry(
                                                                clientIndex, entryIndex);
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text('Удалить',
                                                              style: TextStyle(
                                                                  color: Colors.red)),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                        ],
                                      );
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              showRecipeDialog(context,
                                                  clientRecipe: clientRecipe,
                                                  index: clientIndex);
                                            },
                                            icon: const Icon(Icons.add, color: Colors.blue),
                                            label: const Text('Добавить запись',
                                                style: TextStyle(color: Colors.blue)),
                                          ),
                                          IconButton(
                                            tooltip: 'Удалить клиента',
                                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Удалить клиента?'),
                                                  content: const Text(
                                                      'Вы уверены, что хотите удалить этого клиента и все его записи?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Отмена'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteClientRecipe(clientIndex);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Удалить',
                                                          style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showRecipeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
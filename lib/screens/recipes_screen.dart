import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:stylist_notebook/models/client_recipe.dart';
import 'package:stylist_notebook/models/recipe_entry.dart';
import 'package:stylist_notebook/theme/theme.dart';

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
            .where((client) => client.clientName.toLowerCase().contains(query))
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
    TextEditingController earningsController =
        TextEditingController(text: entryToEdit?.earnings.toString() ?? '');
    List<TextEditingController> recipeControllers =
        (entryToEdit?.recipes ?? [''])
            .map((r) => TextEditingController(text: r))
            .toList();
    DateTime selectedDate = entryToEdit?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Text(
                clientRecipe == null
                    ? 'Новый клиент'
                    : entryToEdit == null
                        ? 'Новая запись'
                        : 'Редактировать запись',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                          decoration: InputDecoration(
                            hintText: 'Введите имя клиента',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: selectedDate,
                          use24hFormat: true,
                          backgroundColor: Colors.white,
                          onDateTimeChanged: (DateTime value) {
                            setDialogState(() {
                              selectedDate = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Рецепт:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ...recipeControllers.asMap().entries.map((entry) {
                        int idx = entry.key;
                        TextEditingController controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: 'Введите рецепт ${idx + 1}',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                            ),
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            recipeControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label: const Text(
                          'Добавить рецепт',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: earningsController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Введите сумму (₽)',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                  child: Text(
                    clientRecipe == null ? 'Добавить' : 'Сохранить',
                  ),
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
    return Theme(
      data: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleMedium: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
      ),
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Поиск по имени клиента',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      suffixIcon: AnimatedOpacity(
                        opacity: searchController.text.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            _onSearchChanged();
                            searchFocusNode.requestFocus();
                          },
                        ),
                      ),
                    ),
                  ),
                  if (showSuggestions && searchController.text.isNotEmpty)
                    Positioned(
                      top: 56,
                      left: 0,
                      right: 0,
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredRecipes.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                tileColor: Colors.white,
                                selectedColor: Colors.white,
                                title: Text(
                                  filteredRecipes[index].clientName,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
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
                  ? Center(
                      child: Text(
                        'Нет рецептов',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final clientRecipe = filteredRecipes[index];
                        final clientIndex = clientRecipes.indexOf(clientRecipe);
                        final isExpanded = expandedStates[clientIndex] ?? false;
                        return Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          clientRecipe.clientName,
                                          style:
                                              Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isExpanded ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: const Icon(
                                          Icons.expand_more,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: Container(),
                                  secondChild: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...clientRecipe.entries.asMap().entries.map((entry) {
                                        final entryIndex = entry.key;
                                        final recipeEntry = entry.value;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
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
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  Text(
                                                    'Рецепт:',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  ...recipeEntry.recipes
                                                      .asMap()
                                                      .entries
                                                      .map((recipe) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(left: 8.0),
                                                      child: Text(
                                                        '${recipe.key + 1}. ${recipe.value}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    );
                                                  }),
                                                  if (recipeEntry.earnings > 0)
                                                    Text(
                                                      'Заработано: ${recipeEntry.earnings.toStringAsFixed(2)} ₽',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                              color: Colors.green),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(16.0),
                                                        ),
                                                        title: Text(
                                                          'Удалить запись?',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .titleLarge,
                                                        ),
                                                        content: Text(
                                                          'Вы уверены, что хотите удалить эту запись?',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(context),
                                                            child: const Text('Отмена',
                                                                style: TextStyle(
                                                                    color: Colors.grey)),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              deleteRecipeEntry(
                                                                  clientIndex, entryIndex);
                                                              Navigator.pop(context);
                                                            },
                                                            child: const Text(
                                                              'Удалить',
                                                              style: TextStyle(
                                                                  color: Colors.red),
                                                            ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                showRecipeDialog(context,
                                                    clientRecipe: clientRecipe,
                                                    index: clientIndex);
                                              },
                                              icon: const Icon(Icons.add,
                                                  color: Colors.blue),
                                              label: const Text(
                                                'Добавить запись',
                                                style: TextStyle(color: Colors.blue),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Удалить клиента',
                                              icon: const Icon(Icons.delete_forever,
                                                  color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(16.0),
                                                    ),
                                                    title: Text(
                                                      'Удалить клиента?',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge,
                                                    ),
                                                    content: Text(
                                                      'Вы уверены, что хотите удалить этого клиента и все его записи?',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(context),
                                                        child: const Text('Отмена',
                                                            style: TextStyle(
                                                                color: Colors.grey)),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteClientRecipe(clientIndex);
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text(
                                                          'Удалить',
                                                          style:
                                                              TextStyle(color: Colors.red),
                                                        ),
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
                                  crossFadeState: isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 200),
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
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: AppColors.white,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
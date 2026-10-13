import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

class Item {
  Item(this.name);

  String name;
  bool bought = false;
  int quantity = 1;
  String note = '';
  String category = 'Food';
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final items = [Item('Milk'), Item('Bread'), Item('Rice')];
  final controller = TextEditingController();
  String filter = 'All';

  void addItem() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an item first')),
      );
      return;
    }

    final match = items.where(
          (item) => item.name.toLowerCase() == text.toLowerCase(),
    );

    if (match.isNotEmpty) {
      final existing = match.first;
      setState(() {
        existing.quantity++;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${existing.name} is already on the list: now ×${existing.quantity}',
          ),
        ),
      );
      controller.clear();
      return;
    }

    setState(() {
      items.add(Item(text));
    });
    controller.clear();
  }

  void clearBought() {
    setState(() {
      items.removeWhere((item) => item.bought);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = items.where((item) => !item.bought).length;

    List<Item> shown;
    if (filter == 'To buy') {
      shown = items.where((i) => !i.bought).toList();
    } else if (filter == 'Bought') {
      shown = items.where((i) => i.bought).toList();
    } else {
      final toBuy = items.where((i) => !i.bought).toList();
      final bought = items.where((i) => i.bought).toList();
      shown = [...toBuy, ...bought];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} ($left left)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Remove bought',
            onPressed: clearBought,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Add an item'),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: filter == 'All',
                  onSelected: (_) => setState(() => filter = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: filter == 'To buy',
                  onSelected: (_) => setState(() => filter = 'To buy'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: filter == 'Bought',
                  onSelected: (_) => setState(() => filter = 'Bought'),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your list is empty'))
                : shown.isEmpty
                ? const Center(child: Text('Nothing here'))
                : ListView.builder(
              itemCount: shown.length,
              itemBuilder: (context, index) {
                final item = shown[index];

                return ListTile(
                  leading: Icon(
                    item.bought
                        ? Icons.check_circle
                        : Icons.shopping_basket,
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.bought
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text('${item.category} · ${item.note}'),
                  onTap: () {
                    setState(() {
                      item.bought = !item.bought;
                    });
                  },
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsScreen(item: item),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (item.quantity > 1) item.quantity--;
                          });
                        },
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            item.quantity++;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final removed = item;
                          final position = items.indexOf(removed);
                          setState(() {
                            items.remove(removed);
                          });
                          ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content:
                              Text('${removed.name} removed'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  setState(() {
                                    items.insert(position, removed);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController noteController;
  late String category;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    category = widget.item.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a name first')),
      );
      return;
    }
    widget.item.name = name;
    widget.item.note = noteController.text.trim();
    widget.item.category = category;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final c in ['Food', 'Drinks', 'Home'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
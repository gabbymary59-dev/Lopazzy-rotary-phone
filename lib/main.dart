import 'package:flutter/material.dart';

void main() {
  runApp(const JournalApp());
}

// =============================================================================
// 1. MODEL
// =============================================================================
class Journal {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  bool isFavourite;

  Journal({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavourite = false,
  });

  Journal copyWith({
    String? title,
    String? content,
    bool? isFavourite,
  }) {
    return Journal(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}

// =============================================================================
// 2. MAIN APPLICATION WIDGET
// =============================================================================
class JournalApp extends StatelessWidget {
  const JournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// =============================================================================
// 3. HOME SCREEN
// =============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Journal> _journals = [
    Journal(
      id: '1',
      title: 'Welcome to My Journal',
      content: 'This single-file code is running live inside GitHub Codespaces!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isFavourite: true,
    ),
    Journal(
      id: '2',
      title: 'Flutter Web & GitHub Codespaces',
      content: 'Demonstrating complete CRUD logic and state navigation seamlessly.',
      createdAt: DateTime.now(),
    ),
  ];

  String _searchQuery = '';
  bool _showOnlyFavourites = false;

  void _addJournal(String title, String content) {
    setState(() {
      _journals.insert(
        0,
        Journal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          content: content,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _updateJournal(String id, String newTitle, String newContent) {
    setState(() {
      final index = _journals.indexWhere((j) => j.id == id);
      if (index != -1) {
        _journals[index] = _journals[index].copyWith(
          title: newTitle,
          content: newContent,
        );
      }
    });
  }

  void _deleteJournal(String id) {
    setState(() {
      _journals.removeWhere((j) => j.id == id);
    });
  }

  void _toggleFavourite(String id) {
    setState(() {
      final index = _journals.indexWhere((j) => j.id == id);
      if (index != -1) {
        _journals[index].isFavourite = !_journals[index].isFavourite;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredJournals = _journals.where((journal) {
      final matchesSearch = journal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          journal.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFav = _showOnlyFavourites ? journal.isFavourite : true;
      return matchesSearch && matchesFav;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyFavourites ? Icons.favorite : Icons.favorite_border,
              color: _showOnlyFavourites ? Colors.red : null,
            ),
            onPressed: () {
              setState(() => _showOnlyFavourites = !_showOnlyFavourites);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search entries...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredJournals.isEmpty
                ? const Center(
                    child: Text(
                      'No journals found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredJournals.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final item = filteredJournals[index];
                      return Dismissible(
                        key: Key(item.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteJournal(item.id),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              item.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                item.isFavourite ? Icons.favorite : Icons.favorite_border,
                                color: item.isFavourite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _toggleFavourite(item.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JournalDetailScreen(
                                    journal: item,
                                    onEdit: (t, c) => _updateJournal(item.id, t, c),
                                  ),
                                ),
                              );
                            },
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalEditScreen(
                onSave: _addJournal,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =============================================================================
// 4. JOURNAL DETAIL SCREEN
// =============================================================================
class JournalDetailScreen extends StatelessWidget {
  final Journal journal;
  final Function(String title, String content) onEdit;

  const JournalDetailScreen({
    super.key,
    required this.journal,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JournalEditScreen(
                    journal: journal,
                    onSave: (t, c) {
                      onEdit(t, c);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              journal.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${journal.createdAt.toString().split('.')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Text(
              journal.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 5. CREATE / EDIT SCREEN
// =============================================================================
class JournalEditScreen extends StatefulWidget {
  final Journal? journal;
  final Function(String title, String content) onSave;

  const JournalEditScreen({super.key, this.journal, required this.onSave});

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.journal?.title ?? '');
    _contentController = TextEditingController(text: widget.journal?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }
    widget.onSave(_titleController.text.trim(), _contentController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journal == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
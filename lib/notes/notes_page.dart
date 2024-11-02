import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/bottom_nav_bar.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'package:the_bridge_app/global_helpers.dart';
import 'package:the_bridge_app/widgets/common_app_bar.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.notes.isEmpty) {
          _getNotes();
        }

        List<Note> filteredNotes = notesProvider.notes.where((note) {
          bool matchesSearch = note.content.toLowerCase().contains(_searchQuery.toLowerCase());
          bool matchesDate = _dateRange == null || (note.timestamp.isAfter(_dateRange!.start) && note.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1))));
          return matchesSearch && matchesDate;
        }).toList();

        return Scaffold(
          appBar: CommonAppBar(
            title: 'Notes',
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                          hintText: 'Search notes...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_dateRange != null) ...[
                      Tooltip(
                        message: 'Clear date filter',
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _dateRange = null),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Tooltip(
                      message: _dateRange == null ? 'Filter by date' : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                      child: FilterChip(
                        label: Text(_dateRange == null ? 'Filter' : 'Filtered'),
                        selected: _dateRange != null,
                        onSelected: (_) => _selectDateRange(),
                        avatar: Icon(
                          _dateRange == null ? Icons.filter_list : Icons.date_range,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: filteredNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        notesProvider.notes.isEmpty ? 'No notes yet' : 'No matching notes found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _showAddNoteDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add a note'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showEditNoteDialog(note),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.content,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.edit),
                                                title: const Text('Edit'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _showEditNoteDialog(note);
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.delete,
                                                  color: Theme.of(context).colorScheme.error,
                                                ),
                                                title: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  context.read<NotesProvider>().deleteNoteById(note.id!);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatTimestamp(note.timestamp),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddNoteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 1, // Adjust index based on your setup
            onItemTapped: (index) => onItemTapped(index, context),
          ),
        );
      },
    );
  }

  void _getNotes() {
    context.read<NotesProvider>().fetchNotes();
  }

  void _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showEditNoteDialog(Note note) {
    TextEditingController noteController = TextEditingController(text: note.content);
    FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Edit Note',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: noteController,
                  focusNode: focusNode,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts here...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        if (noteController.text.isNotEmpty) {
                          note.content = noteController.text;
                          context.read<NotesProvider>().updateNoteContent(note);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => focusNode.dispose());

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  void _showAddNoteDialog() {
    TextEditingController noteController = TextEditingController();
    FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Note',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: noteController,
                  focusNode: focusNode,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts here...',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        if (noteController.text.isNotEmpty) {
                          final newNote = Note(
                            content: noteController.text,
                            step: -1,
                            timestamp: DateTime.now(),
                          );
                          context.read<NotesProvider>().addNote(newNote);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) => focusNode.dispose());

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }
}

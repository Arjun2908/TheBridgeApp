import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:the_bridge_app/models/note.dart';
import 'package:the_bridge_app/providers/notes_provider.dart';

import 'package:the_bridge_app/bottom_nav_bar.dart';
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
  void initState() {
    super.initState();
    // Fetch notes when the page is first loaded
    Future.microtask(() => context.read<NotesProvider>().fetchNotes());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.isLoading) {
          return Scaffold(
            appBar: const CommonAppBar(title: 'Notes'),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/illustrations/loading_notes.svg',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading your notes...',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
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
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          notesProvider.notes.isEmpty ? 'assets/illustrations/no_notes.svg' : 'assets/illustrations/no_matches.svg',
                          width: 240,
                          height: 240,
                        ),
                        Text(
                          notesProvider.notes.isEmpty ? 'No notes yet' : 'No matching notes found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notesProvider.notes.isEmpty ? 'Start capturing your thoughts and insights' : 'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (notesProvider.notes.isEmpty)
                          FilledButton.icon(
                            onPressed: _showAddNoteDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Note'),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _dateRange = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    bool isPressed = false;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return GestureDetector(
                          onTapDown: (_) => setState(() => isPressed = true),
                          onTapUp: (_) {
                            setState(() => isPressed = false);
                            _showEditNoteDialog(note);
                          },
                          onTapCancel: () => setState(() => isPressed = false),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 150),
                            scale: isPressed ? 0.98 : 1.0,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: isPressed ? 5 : 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                          ),
                        );
                      },
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      focusNode: focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          if (noteController.text.isNotEmpty) {
                            note.content = noteController.text;
                            context.read<NotesProvider>().updateNoteContent(note);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      focusNode: focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          if (noteController.text.isNotEmpty) {
                            final newNote = Note(
                              content: noteController.text,
                              step: -1,
                              timestamp: DateTime.now(),
                            );
                            context.read<NotesProvider>().addNote(newNote);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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

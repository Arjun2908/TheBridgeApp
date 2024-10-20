import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/bottom_nav_bar.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'package:the_bridge_app/global_helpers.dart';

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
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.notes.isEmpty) {
          _getNotes();
        }
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: const Text('Saved Notes', style: TextStyle(fontSize: 22)),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: _selectDateRange,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        hintText: 'Search Notes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: notesProvider.notes.isEmpty
                ? const Center(child: Text('No notes available'))
                : ListView.builder(
                    itemCount: notesProvider.notes.length,
                    itemBuilder: (context, index) {
                      List<Note> filteredNotes = notesProvider.notes.where((note) {
                        bool matchesSearch = note.content.toLowerCase().contains(_searchQuery.toLowerCase());
                        bool matchesDate = _dateRange == null || (note.timestamp.isAfter(_dateRange!.start) && note.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1))));

                        return matchesSearch && matchesDate;
                      }).toList();

                      if (filteredNotes.isEmpty) {
                        return Container();
                      }

                      final note = filteredNotes[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            title: Text(
                              note.content,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    formatTimestamp(note.timestamp),
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditNoteDialog(note);
                                } else if (value == 'delete') {
                                  context.read<NotesProvider>().deleteNoteById(note.id!);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showEditNoteDialog(note),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddNoteDialog,
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 1, // Adjust index based on your setup
            onItemTapped: (index) => onItemTapped(index, context),
          ),
        );
      },
    );
  }

  void _showEditNoteDialog(Note note) {
    TextEditingController noteController = TextEditingController(text: note.content);
    FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: noteController,
            focusNode: focusNode,
            decoration: const InputDecoration(hintText: 'Edit your note here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  note.content = noteController.text;
                  context.read<NotesProvider>().updateNoteContent(note);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      focusNode.dispose();
    });

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
            padding: const EdgeInsets.all(16.0),
            width: MediaQuery.of(context).size.width * 0.9, // Adjust the width as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Note', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Enter your note here',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
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
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      focusNode.dispose();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }
}

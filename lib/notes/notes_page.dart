import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/bottom_nav_bar.dart';
import 'package:the_bridge_app/video-player/consts.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.notes.isEmpty) {
          _getNotes();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Notes'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Notes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ),
            ),
          ),
          body: Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              List<Note> filteredNotes = notesProvider.notes.where((note) {
                return note.content.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              return ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return ListTile(
                    title: Text(note.content),
                    subtitle: Text('${steps[note.step].additionalText} - ${formatTimestamp(note.timestamp)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditNoteDialog(note);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<NotesProvider>().deleteNoteById(note.id!);
                          },
                        ),
                      ],
                    ),
                    onTap: () => _showEditNoteDialog(note), // Edit note on tap
                  );
                },
              );
            },
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: 1,
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

    // Ensure the TextField is focused when the dialog is shown
    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }
}

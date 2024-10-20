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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                subtitle: Text('Step ${note.step} - ${note.timestamp}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<NotesProvider>().deleteNoteById(note.id!);
                  },
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
  }

  void _showEditNoteDialog(Note note) {
    TextEditingController noteController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: noteController,
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
    );
  }
}

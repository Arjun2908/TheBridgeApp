import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_helper.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Note> get notes => _notes;

  Future<void> fetchNotes() async {
    _notes = await _dbHelper.getNotes();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _dbHelper.insertNote(note);
    await fetchNotes();
  }

  Future<void> deleteNoteById(int id) async {
    await _dbHelper.deleteNote(id);
    await fetchNotes();
  }

  Future<void> updateNoteContent(Note note) async {
    await _dbHelper.updateNote(note);
    await fetchNotes();
  }
}

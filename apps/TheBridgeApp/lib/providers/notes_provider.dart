import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/database_helper.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    try {
      _isLoading = true;
      notifyListeners();
      _notes = await _dbHelper.getNotes();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllByStepId(int stepId) async {
    try {
      _isLoading = true;
      notifyListeners();
      _notes = await _dbHelper.getNotesByStepId(stepId);
    } catch (e) {
      debugPrint('Error fetching notes by step ID: $e');
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _dbHelper.insertNote(note);
      await fetchNotes();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> deleteNoteById(int id) async {
    try {
      await _dbHelper.deleteNote(id);
      await fetchNotes();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  Future<void> updateNoteContent(Note note) async {
    try {
      await _dbHelper.updateNote(note);
      await fetchNotes();
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }
}

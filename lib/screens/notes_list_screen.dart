import 'dart:async';

import 'package:flutter/material.dart';

import '../db/notes_repository.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _allNotes = [];
  List<Note> _displayed = [];
  bool _loading = true;
  Timer? _debounce;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final notes = await NotesRepository.instance.getAll();
    if (!mounted) return;
    setState(() {
      _allNotes = notes;
      _displayed = notes;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = query.trim().isEmpty
          ? _allNotes
          : await NotesRepository.instance.search(query.trim());
      if (!mounted) return;
      setState(() => _displayed = results);
    });
  }

  Future<void> _delete(Note note) async {
    setState(() {
      _allNotes.removeWhere((n) => n.id == note.id);
      _displayed.removeWhere((n) => n.id == note.id);
    });
    await NotesRepository.instance.delete(note.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Note deleted'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await NotesRepository.instance.insert(note);
              await _loadAll();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search notes…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _displayed.isEmpty
                    ? const Center(child: Text('No notes yet'))
                    : ListView.builder(
                        itemCount: _displayed.length,
                        itemBuilder: (context, index) {
                          final note = _displayed[index];
                          return Dismissible(
                            key: ValueKey(note.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _delete(note),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red.shade400,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: NoteCard(note: note),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

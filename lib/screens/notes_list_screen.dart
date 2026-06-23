import 'dart:async';

import 'package:flutter/material.dart';

import '../db/notes_repository.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'note_edit_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _allNotes = [];
  List<Note> _displayed = [];
  String? _activeTag;
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
      _applyFilters();
      _loading = false;
    });
  }

  void _applyFilters() {
    var notes = _allNotes;
    if (_activeTag != null) {
      notes = notes.where((n) => n.tags.contains(_activeTag!)).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      notes = notes
          .where(
            (n) =>
                n.title.toLowerCase().contains(q) ||
                n.body.toLowerCase().contains(q),
          )
          .toList();
    }
    _displayed = notes;
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(_applyFilters),
    );
  }

  void _onTagTap(String tag) {
    setState(() {
      _activeTag = _activeTag == tag ? null : tag;
      _applyFilters();
    });
  }

  Future<void> _openEditor(Note? note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)),
    );
    if (mounted) _loadAll();
  }

  Future<void> _delete(Note note) async {
    setState(() {
      _allNotes.removeWhere((n) => n.id == note.id);
      _applyFilters();
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
              if (mounted) _loadAll();
            },
          ),
        ),
      );
  }

  List<String> get _allTags {
    final tags = _allNotes.expand((n) => n.tags).toSet().toList();
    tags.sort();
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final tags = _allTags;
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
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: tags.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final tag = tags[i];
                  return FilterChip(
                    label: Text(tag),
                    selected: tag == _activeTag,
                    onSelected: (_) => _onTagTap(tag),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _displayed.isEmpty
                    ? Center(
                        child: Text(
                          _activeTag != null
                              ? 'No notes tagged "$_activeTag"'
                              : 'No notes yet',
                        ),
                      )
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
                            child: NoteCard(
                              note: note,
                              onTap: () => _openEditor(note),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab',
        onPressed: () => _openEditor(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

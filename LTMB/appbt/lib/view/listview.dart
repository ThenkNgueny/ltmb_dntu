import 'package:flutter/material.dart';
import '../db/DatabaseHelper.dart';
import '../model/Note.dart';
import 'NoteDetailScreen.dart';
import 'NoteItem.dart';
import 'NoteForm.dart';

class NoteView extends StatefulWidget {
  @override
  _NoteViewState createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  List<Note> _notes = [];
  bool _isLoading = true;
  bool _isGridView = false;
  int? _filterPriority;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await NoteDatabaseHelper.instance.getAllNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  List<Note> get _filteredNotes {
    List<Note> filtered = _notes;
    if (_filterPriority != null) {
      filtered = filtered.where((note) => note.priority == _filterPriority).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) => note.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm ghi chú...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _filterPriority = value == -1 ? null : value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: -1, child: Text('Tất cả')),
              PopupMenuItem(value: 1, child: Text('Ưu tiên 1')),
              PopupMenuItem(value: 2, child: Text('Ưu tiên 2')),
              PopupMenuItem(value: 3, child: Text('Ưu tiên 3')),
            ],
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredNotes.isEmpty
          ? Center(child: Text('Không có ghi chú nào'))
          : _isGridView
          ? GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 2,
        ),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
      )
          : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailScreen(
              note: note,
              onEdit: () {
                Navigator.pop(context);
                _showNoteDialog(note: note);
              },
            ),
          ),
        );
      },
      child: NoteItem(
        note: note,
        onEdit: () => _showNoteDialog(note: note),
        onDelete: () => _showDeleteDialog(note),
      ),
    );
  }

  void _showNoteDialog({Note? note}) {
    showDialog(
      context: context,
      builder: (context) => NoteForm(
        note: note,
        onSave: (newNote) async {
          if (note == null) {
            await NoteDatabaseHelper.instance.createNote(newNote);
          } else {
            await NoteDatabaseHelper.instance.updateNote(newNote);
          }
          _loadNotes();
        },
      ),
    );
  }

  void _showDeleteDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa ghi chú'),
        content: Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await NoteDatabaseHelper.instance.deleteNote(note.id!);
              _loadNotes();
              Navigator.pop(context);
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

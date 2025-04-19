import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;

  const NoteForm({Key? key, this.note, required this.onSave}) : super(key: key);

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  List<String> _tags = [];
  int _priority = 2;
  Color _selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _selectedColor = Color(int.tryParse(widget.note!.color ?? '') ?? 0xFFFFFFFF);
      _tags = widget.note!.tags ?? [];
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _pickColor() async {
    Color pickedColor = _selectedColor;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              pickedColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Chọn'),
          )
        ],
      ),
    );
    setState(() => _selectedColor = pickedColor);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Thêm Ghi Chú' : 'Chỉnh sửa Ghi Chú'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Tiêu đề không được để trống' : null,
              ),
              // Nội dung
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 3,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Nội dung không được để trống' : null,
              ),
              // Mức độ ưu tiên
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Cao')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Thấp')),
                ],
                onChanged: (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: 10),
              // Bộ chọn màu
              Row(
                children: [
                  const Text("Màu: "),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Thêm nhãn
              TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: 'Thêm nhãn',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_tagController.text),
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: _tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final note = Note(
                id: widget.note?.id,
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
                priority: _priority,
                createdAt: widget.note?.createdAt ?? DateTime.now(),
                modifiedAt: DateTime.now(),
                tags: _tags,
                color: _selectedColor.value.toString(),
              );
              widget.onSave(note);
              Navigator.pop(context);
            }
          },
          child: Text(widget.note == null ? 'Lưu' : 'Cập nhật'),
        ),
      ],
    );
  }
}

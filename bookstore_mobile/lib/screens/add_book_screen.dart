import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _copiesController = TextEditingController(text: '10');

  final ApiService _apiService = ApiService();
  bool _saving = false;

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _saving = true);

    final body = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'copies': int.tryParse(_copiesController.text.trim()) ?? 10,
    };

    final response = await _apiService.addBook(token, body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _authorController, decoration: const InputDecoration(labelText: 'Author')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: _copiesController, decoration: const InputDecoration(labelText: 'Copies')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Book'),
            ),
          ],
        ),
      ),
    );
  }
}
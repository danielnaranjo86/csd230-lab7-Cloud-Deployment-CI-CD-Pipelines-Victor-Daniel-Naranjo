import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'add_book_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final ApiService _apiService = ApiService();

  List<Book> _books = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      final response = await _apiService.getBooks(token);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _books = data.map((item) => Book.fromJson(item)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load books';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error: $e';
      });
    }
  }

  Future<void> _addToCart(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      final response = await _apiService.addToCart(token, id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusCode == 200
              ? 'Book added to cart'
              : 'Failed to add to cart'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request error')),
      );
    }
  }

  Future<void> _deleteBook(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final response = await _apiService.deleteBook(token, id);
    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _loadBooks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  Future<void> _editBookDialog(Book book) async {
    final titleController = TextEditingController(text: book.title);
    final authorController = TextEditingController(text: book.author);
    final priceController = TextEditingController(text: book.price.toString());
    final copiesController = TextEditingController(text: book.copies.toString());

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: authorController, decoration: const InputDecoration(labelText: 'Author')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
              TextField(controller: copiesController, decoration: const InputDecoration(labelText: 'Copies')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'id': book.id,
                'title': titleController.text.trim(),
                'author': authorController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0,
                'copies': int.tryParse(copiesController.text.trim()) ?? 10,
              };

              final response = await _apiService.updateBook(token, book.id, body);
              if (!mounted) return;

              Navigator.pop(context);

              if (response.statusCode == 200) {
                await _loadBooks();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Update failed')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      drawer: const AppDrawer(),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
          _loadBooks();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : RefreshIndicator(
        onRefresh: _loadBooks,
        child: ListView.builder(
          itemCount: _books.length,
          itemBuilder: (context, index) {
            final book = _books[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(book.title),
                subtitle: Text(
                  'Author: ${book.author}\nPrice: \$${book.price.toStringAsFixed(2)}',
                ),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _addToCart(book.id),
                    ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _editBookDialog(book),
                        icon: const Icon(Icons.edit),
                      ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _deleteBook(book.id),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
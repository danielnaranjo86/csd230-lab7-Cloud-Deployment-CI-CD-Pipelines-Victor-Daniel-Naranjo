import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guitar.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'add_guitar_screen.dart';

class GuitarsScreen extends StatefulWidget {
  const GuitarsScreen({super.key});

  @override
  State<GuitarsScreen> createState() => _GuitarsScreenState();
}

class _GuitarsScreenState extends State<GuitarsScreen> {
  final ApiService _apiService = ApiService();

  List<Guitar> _guitars = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadGuitars();
  }

  Future<void> _loadGuitars() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      final response = await _apiService.getGuitars(token);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _guitars = data.map((e) => Guitar.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load guitars';
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

    final response = await _apiService.addToCart(token, id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.statusCode == 200
            ? 'Guitar added to cart'
            : 'Failed to add to cart'),
      ),
    );
  }

  Future<void> _deleteGuitar(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final response = await _apiService.deleteGuitar(token, id);
    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _loadGuitars();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  Future<void> _editGuitarDialog(Guitar guitar) async {
    final brandController = TextEditingController(text: guitar.brand);
    final modelController = TextEditingController(text: guitar.model);
    final priceController = TextEditingController(text: guitar.price.toString());

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Guitar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand')),
            TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Model')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'id': guitar.id,
                'brand': brandController.text.trim(),
                'model': modelController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0,
              };

              final response = await _apiService.updateGuitar(token, guitar.id, body);
              if (!mounted) return;

              Navigator.pop(context);

              if (response.statusCode == 200) {
                await _loadGuitars();
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
      appBar: AppBar(title: const Text('Guitars')),
      drawer: const AppDrawer(),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGuitarScreen()),
          );
          _loadGuitars();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : RefreshIndicator(
        onRefresh: _loadGuitars,
        child: ListView.builder(
          itemCount: _guitars.length,
          itemBuilder: (context, index) {
            final guitar = _guitars[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('${guitar.brand} ${guitar.model}'),
                subtitle: Text('Price: \$${guitar.price.toStringAsFixed(2)}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => _addToCart(guitar.id),
                      icon: const Icon(Icons.add_shopping_cart),
                    ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _editGuitarDialog(guitar),
                        icon: const Icon(Icons.edit),
                      ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _deleteGuitar(guitar.id),
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
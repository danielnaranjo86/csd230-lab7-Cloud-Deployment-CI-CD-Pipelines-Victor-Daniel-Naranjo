import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/magazine.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'add_magazine_screen.dart';

class MagazinesScreen extends StatefulWidget {
  const MagazinesScreen({super.key});

  @override
  State<MagazinesScreen> createState() => _MagazinesScreenState();
}

class _MagazinesScreenState extends State<MagazinesScreen> {
  final ApiService _apiService = ApiService();

  List<Magazine> _magazines = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMagazines();
  }

  Future<void> _loadMagazines() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      final response = await _apiService.getMagazines(token);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _magazines = data.map((e) => Magazine.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load magazines';
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
            ? 'Magazine added to cart'
            : 'Failed to add to cart'),
      ),
    );
  }

  Future<void> _deleteMagazine(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final response = await _apiService.deleteMagazine(token, id);
    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _loadMagazines();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  Future<void> _editMagazineDialog(Magazine mag) async {
    final titleController = TextEditingController(text: mag.title);
    final priceController = TextEditingController(text: mag.price.toString());
    final copiesController = TextEditingController(text: mag.copies.toString());
    final orderQtyController = TextEditingController(text: mag.orderQty.toString());
    final currentIssueController = TextEditingController(text: mag.currentIssue);

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Magazine'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
              TextField(controller: copiesController, decoration: const InputDecoration(labelText: 'Copies')),
              TextField(controller: orderQtyController, decoration: const InputDecoration(labelText: 'Order Qty')),
              TextField(controller: currentIssueController, decoration: const InputDecoration(labelText: 'Current Issue')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'id': mag.id,
                'title': titleController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0,
                'copies': int.tryParse(copiesController.text.trim()) ?? 0,
                'orderQty': int.tryParse(orderQtyController.text.trim()) ?? 0,
                'currentIssue': currentIssueController.text.trim(),
              };

              final response = await _apiService.updateMagazine(token, mag.id, body);
              if (!mounted) return;

              Navigator.pop(context);

              if (response.statusCode == 200) {
                await _loadMagazines();
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
      appBar: AppBar(title: const Text('Magazines')),
      drawer: const AppDrawer(),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMagazineScreen()),
          );
          _loadMagazines();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : RefreshIndicator(
        onRefresh: _loadMagazines,
        child: ListView.builder(
          itemCount: _magazines.length,
          itemBuilder: (context, index) {
            final mag = _magazines[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(mag.title),
                subtitle: Text(
                  'Issue: ${mag.currentIssue}\nPrice: \$${mag.price.toStringAsFixed(2)} | Order Qty: ${mag.orderQty}',
                ),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => _addToCart(mag.id),
                      icon: const Icon(Icons.add_shopping_cart),
                    ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _editMagazineDialog(mag),
                        icon: const Icon(Icons.edit),
                      ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _deleteMagazine(mag.id),
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
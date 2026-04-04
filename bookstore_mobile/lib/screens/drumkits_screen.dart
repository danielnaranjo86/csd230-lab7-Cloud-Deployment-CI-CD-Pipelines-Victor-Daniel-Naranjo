import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drumkit.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'add_drumkit_screen.dart';

class DrumKitsScreen extends StatefulWidget {
  const DrumKitsScreen({super.key});

  @override
  State<DrumKitsScreen> createState() => _DrumKitsScreenState();
}

class _DrumKitsScreenState extends State<DrumKitsScreen> {
  final ApiService _apiService = ApiService();

  List<DrumKit> _drumKits = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDrumKits();
  }

  Future<void> _loadDrumKits() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      final response = await _apiService.getDrumKits(token);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _drumKits = data.map((e) => DrumKit.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Failed to load drum kits';
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
            ? 'Drum kit added to cart'
            : 'Failed to add to cart'),
      ),
    );
  }

  Future<void> _deleteDrumKit(int id) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final response = await _apiService.deleteDrumKit(token, id);
    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 204) {
      await _loadDrumKits();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  Future<void> _editDrumKitDialog(DrumKit drum) async {
    final brandController = TextEditingController(text: drum.brand);
    final piecesController = TextEditingController(text: drum.pieces?.toString() ?? '');
    final modelController = TextEditingController(text: drum.model?.toString() ?? '');
    final priceController = TextEditingController(text: drum.price.toString());

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Drum Kit'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand')),
              TextField(controller: piecesController, decoration: const InputDecoration(labelText: 'Pieces')),
              TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Model')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final piecesValue = int.tryParse(piecesController.text.trim());

              final body = {
                'id': drum.id,
                'brand': brandController.text.trim(),
                if (piecesValue != null) 'pieces': piecesValue,
                if (modelController.text.trim().isNotEmpty) 'model': modelController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0,
              };

              final response = await _apiService.updateDrumKit(token, drum.id, body);
              if (!mounted) return;

              Navigator.pop(context);

              if (response.statusCode == 200) {
                await _loadDrumKits();
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
      appBar: AppBar(title: const Text('Drum Kits')),
      drawer: const AppDrawer(),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDrumKitScreen()),
          );
          _loadDrumKits();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : RefreshIndicator(
        onRefresh: _loadDrumKits,
        child: ListView.builder(
          itemCount: _drumKits.length,
          itemBuilder: (context, index) {
            final drum = _drumKits[index];
            final secondary = drum.pieces != null
                ? 'Pieces: ${drum.pieces}'
                : (drum.model != null ? 'Model: ${drum.model}' : 'Drum kit');

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(drum.brand),
                subtitle: Text('$secondary\nPrice: \$${drum.price.toStringAsFixed(2)}'),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => _addToCart(drum.id),
                      icon: const Icon(Icons.add_shopping_cart),
                    ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _editDrumKitDialog(drum),
                        icon: const Icon(Icons.edit),
                      ),
                    if (isAdmin)
                      IconButton(
                        onPressed: () => _deleteDrumKit(drum.id),
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
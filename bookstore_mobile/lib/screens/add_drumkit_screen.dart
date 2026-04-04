import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddDrumKitScreen extends StatefulWidget {
  const AddDrumKitScreen({super.key});

  @override
  State<AddDrumKitScreen> createState() => _AddDrumKitScreenState();
}

class _AddDrumKitScreenState extends State<AddDrumKitScreen> {
  final _brandController = TextEditingController();
  final _piecesController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _saving = false;

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _saving = true);

    final piecesValue = int.tryParse(_piecesController.text.trim());

    final body = {
      'brand': _brandController.text.trim(),
      if (piecesValue != null) 'pieces': piecesValue,
      if (_modelController.text.trim().isNotEmpty) 'model': _modelController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
    };

    final response = await _apiService.addDrumKit(token, body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save drum kit')),
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
      appBar: AppBar(title: const Text('Add Drum Kit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand')),
            TextField(controller: _piecesController, decoration: const InputDecoration(labelText: 'Pieces')),
            TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Drum Kit'),
            ),
          ],
        ),
      ),
    );
  }
}